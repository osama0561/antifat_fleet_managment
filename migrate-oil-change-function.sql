-- Oil Change Tracking Function for n8n notifications
-- This function returns vehicles that need oil change (driven 5000+ km since last oil change)

CREATE OR REPLACE FUNCTION get_vehicles_needing_oil_change()
RETURNS TABLE (
  vehicle_id UUID,
  van_code TEXT,
  plate_number TEXT,
  current_odometer BIGINT,
  last_oil_change_odometer BIGINT,
  km_since_oil_change BIGINT
) AS $$
BEGIN
  RETURN QUERY
  WITH latest_odometer AS (
    -- Get the most recent odometer reading for each vehicle
    SELECT DISTINCT ON (vehicle_id)
      vehicle_id,
      odometer_reading
    FROM inspections
    WHERE odometer_reading IS NOT NULL
    ORDER BY vehicle_id, submitted_at DESC
  ),
  last_oil_change AS (
    -- Get the last completed oil change for each vehicle
    SELECT DISTINCT ON (vehicle_id)
      vehicle_id,
      odometer_reading as oil_change_odometer
    FROM maintenance_reports
    WHERE 'oil_change' = ANY(issue_types)
      AND status = 'completed'
      AND odometer_reading IS NOT NULL
    ORDER BY vehicle_id, submitted_at DESC
  )
  SELECT
    v.id as vehicle_id,
    v.van_code,
    v.plate_number,
    COALESCE(lo.odometer_reading, 0)::BIGINT as current_odometer,
    COALESCE(loc.oil_change_odometer, 0)::BIGINT as last_oil_change_odometer,
    (COALESCE(lo.odometer_reading, 0) - COALESCE(loc.oil_change_odometer, 0))::BIGINT as km_since_oil_change
  FROM vehicles v
  LEFT JOIN latest_odometer lo ON lo.vehicle_id = v.id
  LEFT JOIN last_oil_change loc ON loc.vehicle_id = v.id
  WHERE v.status NOT IN ('accident', 'maintenance')
    AND (COALESCE(lo.odometer_reading, 0) - COALESCE(loc.oil_change_odometer, 0)) >= 5000;
END;
$$ LANGUAGE plpgsql;

-- Function to get expiring documents (vehicles)
CREATE OR REPLACE FUNCTION get_expiring_vehicle_documents(days_ahead INTEGER DEFAULT 30)
RETURNS TABLE (
  vehicle_id UUID,
  van_code TEXT,
  plate_number TEXT,
  registration_expiry DATE,
  registration_days_left INTEGER,
  insurance_expiry DATE,
  insurance_days_left INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    v.id as vehicle_id,
    v.van_code,
    v.plate_number,
    v.registration_expiry,
    (v.registration_expiry - CURRENT_DATE)::INTEGER as registration_days_left,
    v.insurance_expiry,
    (v.insurance_expiry - CURRENT_DATE)::INTEGER as insurance_days_left
  FROM vehicles v
  WHERE v.status != 'accident'
    AND (
      (v.registration_expiry IS NOT NULL AND v.registration_expiry <= CURRENT_DATE + days_ahead)
      OR
      (v.insurance_expiry IS NOT NULL AND v.insurance_expiry <= CURRENT_DATE + days_ahead)
    )
  ORDER BY
    LEAST(COALESCE(v.registration_expiry, '2099-12-31'), COALESCE(v.insurance_expiry, '2099-12-31'));
END;
$$ LANGUAGE plpgsql;

-- Function to get expiring driver licenses
CREATE OR REPLACE FUNCTION get_expiring_driver_licenses(days_ahead INTEGER DEFAULT 30)
RETURNS TABLE (
  driver_id UUID,
  full_name TEXT,
  driver_code TEXT,
  phone TEXT,
  license_expiry DATE,
  days_left INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    d.id as driver_id,
    d.full_name,
    d.driver_code,
    d.phone,
    d.license_expiry,
    (d.license_expiry - CURRENT_DATE)::INTEGER as days_left
  FROM drivers d
  WHERE d.is_active = true
    AND d.role = 'driver'
    AND d.license_expiry IS NOT NULL
    AND d.license_expiry <= CURRENT_DATE + days_ahead
  ORDER BY d.license_expiry;
END;
$$ LANGUAGE plpgsql;

-- Function to get overdue pending maintenance (> 48 hours)
CREATE OR REPLACE FUNCTION get_overdue_maintenance()
RETURNS TABLE (
  report_id UUID,
  report_code TEXT,
  driver_name TEXT,
  driver_code TEXT,
  van_code TEXT,
  issue_types TEXT[],
  urgency TEXT,
  description TEXT,
  hours_pending NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.id as report_id,
    m.report_code,
    d.full_name as driver_name,
    d.driver_code,
    v.van_code,
    m.issue_types,
    m.urgency,
    m.description,
    ROUND(EXTRACT(EPOCH FROM (NOW() - m.submitted_at)) / 3600, 1) as hours_pending
  FROM maintenance_reports m
  JOIN drivers d ON d.id = m.driver_id
  JOIN vehicles v ON v.id = m.vehicle_id
  WHERE m.status = 'pending'
    AND m.submitted_at < NOW() - INTERVAL '48 hours'
  ORDER BY m.urgency DESC, m.submitted_at ASC;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_vehicles_needing_oil_change() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_expiring_vehicle_documents(INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_expiring_driver_licenses(INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_overdue_maintenance() TO anon, authenticated;