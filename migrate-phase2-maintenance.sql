-- ========================================
-- FleetCheck Phase 2: Maintenance Reports Table
-- Run this in Supabase SQL Editor
-- ========================================

-- Create maintenance_reports table
CREATE TABLE IF NOT EXISTS maintenance_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    report_code TEXT NOT NULL UNIQUE,
    driver_id UUID REFERENCES drivers(id),
    vehicle_id UUID REFERENCES vehicles(id),

    -- Issue details
    issue_types TEXT[] NOT NULL, -- Array of issue types: engine, brakes, tires, ac, lights, battery, fridge, other
    urgency TEXT NOT NULL CHECK (urgency IN ('low', 'medium', 'high')),
    description TEXT NOT NULL,
    odometer_reading INTEGER,

    -- Photos (optional, up to 3)
    photo_1 TEXT,
    photo_2 TEXT,
    photo_3 TEXT,

    -- Location
    gps_latitude DECIMAL(10, 8),
    gps_longitude DECIMAL(11, 8),
    gps_accuracy DECIMAL(10, 2),

    -- Status tracking
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    assigned_to TEXT, -- Mechanic or workshop name
    resolution_notes TEXT,
    resolved_at TIMESTAMPTZ,

    -- Timestamps
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_maintenance_driver ON maintenance_reports(driver_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_vehicle ON maintenance_reports(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_status ON maintenance_reports(status);
CREATE INDEX IF NOT EXISTS idx_maintenance_urgency ON maintenance_reports(urgency);
CREATE INDEX IF NOT EXISTS idx_maintenance_submitted ON maintenance_reports(submitted_at DESC);

-- Enable RLS (Row Level Security)
ALTER TABLE maintenance_reports ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can insert
CREATE POLICY "Authenticated users can insert maintenance reports"
ON maintenance_reports
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Policy: Authenticated users can view all maintenance reports
-- (For now, all authenticated users can see all reports - admin filtering will be in the app)
CREATE POLICY "Authenticated users can view maintenance reports"
ON maintenance_reports
FOR SELECT
TO authenticated
USING (true);

-- Policy: Authenticated users can update reports
-- (For admin dashboard - proper role check can be added later)
CREATE POLICY "Authenticated users can update maintenance reports"
ON maintenance_reports
FOR UPDATE
TO authenticated
USING (true);

-- ========================================
-- VERIFY TABLE CREATED
-- ========================================
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'maintenance_reports'
ORDER BY ordinal_position;

-- ========================================
-- NOTES:
-- ========================================
-- report_code: Unique identifier (MNT-timestamp)
-- issue_types: Array of strings for multiple issue selection
-- urgency: low (green), medium (yellow), high (red)
-- status: pending → in_progress → completed/cancelled
-- assigned_to: Name of mechanic/workshop handling the repair
-- resolution_notes: What was done to fix the issue
-- resolved_at: When the maintenance was completed

-- ========================================
-- SAMPLE QUERY: View pending high-urgency reports
-- ========================================
-- SELECT
--     m.report_code,
--     d.full_name as driver_name,
--     v.van_code,
--     m.issue_types,
--     m.urgency,
--     m.description,
--     m.submitted_at
-- FROM maintenance_reports m
-- JOIN drivers d ON m.driver_id = d.id
-- JOIN vehicles v ON m.vehicle_id = v.id
-- WHERE m.status = 'pending' AND m.urgency = 'high'
-- ORDER BY m.submitted_at DESC;
