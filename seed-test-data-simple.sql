-- FleetCheck Test Data - Run this in Supabase SQL Editor
-- Creates 10 test maintenance records for n8n testing

-- Step 1: Insert test drivers
INSERT INTO drivers (id, email, full_name, driver_code, phone, role, is_active, driver_type)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'test.driver1@antifat.com', 'Ahmed Test', 'DRV-TEST-001', '+966501234567', 'driver', true, 'permanent'),
  ('22222222-2222-2222-2222-222222222222', 'test.driver2@antifat.com', 'Fatima Test', 'DRV-TEST-002', '+966502345678', 'driver', true, 'permanent'),
  ('33333333-3333-3333-3333-333333333333', 'test.driver3@antifat.com', 'Mohammed Test', 'DRV-TEST-003', '+966503456789', 'driver', true, 'permanent')
ON CONFLICT (id) DO NOTHING;

-- Step 2: Insert test vehicles
INSERT INTO vehicles (id, van_code, plate_number, status, location)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'VAN-TEST-001', 'ABC 1234', 'active', 'Jeddah'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'VAN-TEST-002', 'DEF 5678', 'active', 'Riyadh'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'VAN-TEST-003', 'GHI 9012', 'idle', 'Jeddah')
ON CONFLICT (id) DO NOTHING;

-- Step 3: Insert driver-vehicle assignments
INSERT INTO driver_vehicle_assignments (driver_id, vehicle_id, is_current)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true),
  ('22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', true),
  ('33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', true)
ON CONFLICT DO NOTHING;

-- Step 4: Insert 10 maintenance reports (various urgencies)
INSERT INTO maintenance_reports (report_code, driver_id, vehicle_id, issue_types, urgency, description, odometer_reading, status, submitted_at)
VALUES
-- HIGH URGENCY (3)
('MNT-TEST-001', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', ARRAY['brakes'], 'high', 'Brake noise urgent', 87500, 'pending', NOW() - INTERVAL '2 hours'),
('MNT-TEST-002', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', ARRAY['engine'], 'high', 'Engine clicking noise', 45200, 'pending', NOW() - INTERVAL '5 hours'),
('MNT-TEST-003', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', ARRAY['engine', 'brakes'], 'high', 'Brakes and engine problem', 92100, 'pending', NOW() - INTERVAL '50 hours'),
-- MEDIUM URGENCY (3)
('MNT-TEST-004', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', ARRAY['tires'], 'medium', 'Front tire needs replacement', 87600, 'pending', NOW() - INTERVAL '1 day'),
('MNT-TEST-005', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', ARRAY['battery'], 'medium', 'Battery weak', 45300, 'in_progress', NOW() - INTERVAL '3 days'),
('MNT-TEST-006', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', ARRAY['tires', 'battery'], 'medium', 'Tires and battery', 92200, 'pending', NOW() - INTERVAL '60 hours'),
-- LOW URGENCY (4)
('MNT-TEST-007', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', ARRAY['oil_change'], 'low', 'Oil change due', 87700, 'pending', NOW() - INTERVAL '12 hours'),
('MNT-TEST-008', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', ARRAY['ac'], 'low', 'AC not cooling', 45400, 'completed', NOW() - INTERVAL '5 days'),
('MNT-TEST-009', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', ARRAY['lights'], 'low', 'Rear light not working', 92300, 'pending', NOW() - INTERVAL '6 hours'),
('MNT-TEST-010', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', ARRAY['fridge'], 'low', 'Fridge making noise', 87800, 'pending', NOW() - INTERVAL '3 hours');

-- Step 5: Insert test inspections with issues
INSERT INTO inspections (inspection_code, driver_id, vehicle_id, inspection_type, light_front, light_back, signal_right, signal_left, fridge_status, odometer_reading, submitted_at)
VALUES
('INS-TEST-001', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'receive', true, false, true, true, 'working', 87500, NOW() - INTERVAL '1 day'),
('INS-TEST-002', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'receive', true, true, false, false, 'not_working', 45200, NOW() - INTERVAL '12 hours'),
('INS-TEST-003', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'release', true, true, true, true, 'working', 92100, NOW() - INTERVAL '6 hours');

-- Check what was inserted
SELECT 'Drivers' as table_name, COUNT(*) as count FROM drivers WHERE driver_code LIKE 'DRV-TEST-%'
UNION ALL
SELECT 'Vehicles', COUNT(*) FROM vehicles WHERE van_code LIKE 'VAN-TEST-%'
UNION ALL
SELECT 'Maintenance Reports', COUNT(*) FROM maintenance_reports WHERE report_code LIKE 'MNT-TEST-%'
UNION ALL
SELECT 'Inspections', COUNT(*) FROM inspections WHERE inspection_code LIKE 'INS-TEST-%';
