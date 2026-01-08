-- ========================================
-- FleetCheck Phase 4: Admin Dashboard Setup
-- Run this in Supabase SQL Editor
-- ========================================

-- ========================================
-- 1. ADD ROLE COLUMN TO DRIVERS
-- ========================================
ALTER TABLE drivers
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'driver' CHECK (role IN ('driver', 'admin'));

-- ========================================
-- 2. ADD DRIVER TYPE (PERMANENT/TEMPORARY)
-- ========================================
ALTER TABLE drivers
ADD COLUMN IF NOT EXISTS driver_type TEXT DEFAULT 'permanent' CHECK (driver_type IN ('permanent', 'temporary'));

-- Add temporary assignment dates
ALTER TABLE drivers
ADD COLUMN IF NOT EXISTS temp_start_date DATE,
ADD COLUMN IF NOT EXISTS temp_end_date DATE;

-- ========================================
-- 3. ADD DOCUMENT EXPIRY TRACKING
-- ========================================
ALTER TABLE drivers
ADD COLUMN IF NOT EXISTS license_expiry DATE,
ADD COLUMN IF NOT EXISTS id_expiry DATE;

ALTER TABLE vehicles
ADD COLUMN IF NOT EXISTS registration_expiry DATE,
ADD COLUMN IF NOT EXISTS insurance_expiry DATE,
ADD COLUMN IF NOT EXISTS last_inspection_date DATE;

-- ========================================
-- 4. ADD NOTES FIELD
-- ========================================
ALTER TABLE drivers
ADD COLUMN IF NOT EXISTS admin_notes TEXT;

ALTER TABLE vehicles
ADD COLUMN IF NOT EXISTS admin_notes TEXT;

-- ========================================
-- 5. ADD LAST ACTIVITY TRACKING
-- ========================================
ALTER TABLE drivers
ADD COLUMN IF NOT EXISTS last_login TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS last_inspection TIMESTAMPTZ;

-- ========================================
-- 6. CREATE AUDIT LOG TABLE
-- ========================================
CREATE TABLE IF NOT EXISTS audit_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    admin_email TEXT NOT NULL,
    action TEXT NOT NULL,
    target_type TEXT NOT NULL, -- 'driver', 'vehicle', 'assignment', 'report'
    target_id UUID,
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_admin ON audit_log(admin_email);
CREATE INDEX IF NOT EXISTS idx_audit_action ON audit_log(action);
CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_log(created_at DESC);

-- Enable RLS
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can insert audit logs"
ON audit_log FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Authenticated users can view audit logs"
ON audit_log FOR SELECT TO authenticated USING (true);

-- ========================================
-- 7. UPDATE DRIVER_VEHICLE_ASSIGNMENTS TABLE
-- ========================================
-- Add temporary assignment support
ALTER TABLE driver_vehicle_assignments
ADD COLUMN IF NOT EXISTS is_temporary BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS temp_start_date DATE,
ADD COLUMN IF NOT EXISTS temp_end_date DATE,
ADD COLUMN IF NOT EXISTS original_driver_id UUID REFERENCES drivers(id),
ADD COLUMN IF NOT EXISTS notes TEXT;

-- ========================================
-- 8. CREATE YOUR ADMIN USER
-- ========================================
-- IMPORTANT: Replace 'admin@antifat.com' with your actual admin email
-- Run this AFTER creating the user in Supabase Auth

-- UPDATE drivers SET role = 'admin' WHERE email = 'admin@antifat.com';

-- Or insert a new admin:
-- INSERT INTO drivers (email, full_name, driver_code, role, is_active)
-- VALUES ('admin@antifat.com', 'Admin User', 'ADMIN-001', 'admin', true);

-- ========================================
-- VERIFY CHANGES
-- ========================================
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'drivers'
AND column_name IN ('role', 'driver_type', 'temp_start_date', 'license_expiry', 'last_login')
ORDER BY column_name;

-- ========================================
-- NOTES
-- ========================================
-- role: 'driver' (default) or 'admin'
-- driver_type: 'permanent' (default) or 'temporary' (daily workers)
-- temp_start_date/temp_end_date: For temporary drivers
-- license_expiry/id_expiry: Document tracking
-- last_login/last_inspection: Activity tracking
-- admin_notes: Admin can add notes about driver/vehicle
-- audit_log: Tracks all admin actions
