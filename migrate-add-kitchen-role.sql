-- ========================================
-- FleetCheck: Add Kitchen Role
-- Run this in Supabase SQL Editor FIRST
-- ========================================

-- Drop the existing check constraint and recreate with kitchen role
ALTER TABLE drivers DROP CONSTRAINT IF EXISTS drivers_role_check;

ALTER TABLE drivers ADD CONSTRAINT drivers_role_check
CHECK (role IN ('admin', 'driver', 'kitchen'));

-- Now insert the kitchen user
INSERT INTO drivers (driver_code, full_name, email, phone, role, is_active)
VALUES ('KITCHEN-001', 'موظف المطبخ', 'kitchen@antifat.com', '0500000002', 'kitchen', true)
ON CONFLICT (email) DO UPDATE SET
    role = 'kitchen',
    is_active = true,
    full_name = 'موظف المطبخ';

-- Verify all test users
SELECT driver_code, full_name, email, role, is_active
FROM drivers
WHERE email IN ('okasha@antifat.com', 'kitchen@antifat.com', 'driver@antifat.com');

SELECT 'Kitchen role added and user created!' as status;
