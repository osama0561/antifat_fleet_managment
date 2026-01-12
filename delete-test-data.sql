-- FleetCheck - Delete All Test Data
-- Run this in Supabase SQL Editor to clean up test data

-- Delete in order to respect foreign key constraints
DELETE FROM inspections WHERE inspection_code LIKE 'INS-TEST-%';
DELETE FROM maintenance_reports WHERE report_code LIKE 'MNT-TEST-%';
DELETE FROM driver_vehicle_assignments WHERE driver_id IN (SELECT id FROM drivers WHERE driver_code LIKE 'DRV-TEST-%');
DELETE FROM vehicles WHERE van_code LIKE 'VAN-TEST-%';
DELETE FROM drivers WHERE driver_code LIKE 'DRV-TEST-%';

-- Verify deletion
SELECT 'Test data deleted. Remaining:' as status;
SELECT 'Drivers' as table_name, COUNT(*) as remaining FROM drivers WHERE driver_code LIKE 'DRV-TEST-%'
UNION ALL
SELECT 'Vehicles', COUNT(*) FROM vehicles WHERE van_code LIKE 'VAN-TEST-%'
UNION ALL
SELECT 'Maintenance Reports', COUNT(*) FROM maintenance_reports WHERE report_code LIKE 'MNT-TEST-%'
UNION ALL
SELECT 'Inspections', COUNT(*) FROM inspections WHERE inspection_code LIKE 'INS-TEST-%';
