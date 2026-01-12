-- ========================================
-- FleetCheck: Add Test Users
-- Run this in Supabase SQL Editor
-- ========================================

-- NOTE: First create these users in Supabase Auth:
-- Go to Authentication > Users > Add user
-- 1. okasha@antifat.com / antifat2024
-- 2. kitchen@antifat.com / antifat2024
-- 3. driver@antifat.com / antifat2024

-- ========================================
-- 1. ADMIN USER (okasha@antifat.com)
-- ========================================
INSERT INTO drivers (driver_code, full_name, email, phone, role, is_active)
VALUES ('ADMIN-001', 'عكاشة المدير', 'okasha@antifat.com', '0500000001', 'admin', true)
ON CONFLICT (email) DO UPDATE SET
    role = 'admin',
    is_active = true,
    full_name = 'عكاشة المدير';

-- ========================================
-- 2. KITCHEN STAFF (kitchen@antifat.com)
-- ========================================
INSERT INTO drivers (driver_code, full_name, email, phone, role, is_active)
VALUES ('KITCHEN-001', 'موظف المطبخ', 'kitchen@antifat.com', '0500000002', 'kitchen', true)
ON CONFLICT (email) DO UPDATE SET
    role = 'kitchen',
    is_active = true,
    full_name = 'موظف المطبخ';

-- ========================================
-- 3. DRIVER (driver@antifat.com)
-- ========================================
INSERT INTO drivers (driver_code, full_name, email, phone, role, is_active, driver_type)
VALUES ('DRV-TEST', 'سائق تجريبي', 'driver@antifat.com', '0500000003', 'driver', true, 'permanent')
ON CONFLICT (email) DO UPDATE SET
    role = 'driver',
    is_active = true,
    full_name = 'سائق تجريبي';

-- ========================================
-- VERIFICATION
-- ========================================
SELECT driver_code, full_name, email, role, is_active
FROM drivers
WHERE email IN ('okasha@antifat.com', 'kitchen@antifat.com', 'driver@antifat.com');

SELECT 'Test Users Migration Complete' as status;
