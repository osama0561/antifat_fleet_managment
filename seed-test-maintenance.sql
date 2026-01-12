-- Seed Test Data for n8n Notifications Testing
-- Run this in Supabase SQL Editor
-- Creates 10 maintenance reports with various urgencies and issues

-- First, let's make sure we have test drivers and vehicles
-- Insert test driver if not exists
INSERT INTO drivers (id, email, full_name, driver_code, phone, role, is_active, driver_type)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'test.driver1@antifat.com', 'أحمد محمد التميمي', 'DRV-TEST-001', '+966501234567', 'driver', true, 'permanent'),
  ('22222222-2222-2222-2222-222222222222', 'test.driver2@antifat.com', 'فاطمة علي الحربي', 'DRV-TEST-002', '+966502345678', 'driver', true, 'permanent'),
  ('33333333-3333-3333-3333-333333333333', 'test.driver3@antifat.com', 'محمد عبدالله القحطاني', 'DRV-TEST-003', '+966503456789', 'driver', true, 'permanent')
ON CONFLICT (email) DO NOTHING;

-- Insert test vehicles if not exists
INSERT INTO vehicles (id, van_code, plate_number, status, location, registration_expiry, insurance_expiry)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'VAN-TEST-001', 'ABC 1234', 'active', 'Jeddah', CURRENT_DATE + INTERVAL '60 days', CURRENT_DATE + INTERVAL '90 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'VAN-TEST-002', 'DEF 5678', 'active', 'Riyadh', CURRENT_DATE + INTERVAL '15 days', CURRENT_DATE + INTERVAL '20 days'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'VAN-TEST-003', 'GHI 9012', 'idle', 'Jeddah', CURRENT_DATE + INTERVAL '5 days', CURRENT_DATE + INTERVAL '10 days')
ON CONFLICT (van_code) DO NOTHING;

-- Insert test driver-vehicle assignments
INSERT INTO driver_vehicle_assignments (driver_id, vehicle_id, is_current)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true),
  ('22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', true),
  ('33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', true)
ON CONFLICT DO NOTHING;

-- Insert 10 test maintenance reports
INSERT INTO maintenance_reports (
  report_code, driver_id, vehicle_id, issue_types, urgency, description,
  odometer_reading, status, submitted_at
) VALUES
-- HIGH URGENCY (3 reports)
(
  'MNT-TEST-001',
  '11111111-1111-1111-1111-111111111111',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  ARRAY['brakes'],
  'high',
  'صوت صرير قوي عند الضغط على الفرامل، خاصة عند السرعات المنخفضة. يحتاج فحص عاجل.',
  87500,
  'pending',
  NOW() - INTERVAL '2 hours'
),
(
  'MNT-TEST-002',
  '22222222-2222-2222-2222-222222222222',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  ARRAY['engine'],
  'high',
  'المحرك يصدر صوت طقطقة غريب عند التشغيل. ضوء المحرك مضاء في لوحة القيادة.',
  45200,
  'pending',
  NOW() - INTERVAL '5 hours'
),
(
  'MNT-TEST-003',
  '33333333-3333-3333-3333-333333333333',
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  ARRAY['engine', 'brakes'],
  'high',
  'المركبة لا تستجيب بشكل جيد عند الضغط على الفرامل، والمحرك يسخن بسرعة.',
  92100,
  'pending',
  NOW() - INTERVAL '50 hours'  -- This one is overdue (>48 hours)
),

-- MEDIUM URGENCY (3 reports)
(
  'MNT-TEST-004',
  '11111111-1111-1111-1111-111111111111',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  ARRAY['tires'],
  'medium',
  'الإطار الأمامي الأيسر يحتاج تبديل. النقش متآكل بشكل كبير.',
  87600,
  'pending',
  NOW() - INTERVAL '1 day'
),
(
  'MNT-TEST-005',
  '22222222-2222-2222-2222-222222222222',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  ARRAY['battery'],
  'medium',
  'البطارية ضعيفة، المركبة تحتاج وقت طويل للتشغيل في الصباح.',
  45300,
  'in_progress',
  NOW() - INTERVAL '3 days'
),
(
  'MNT-TEST-006',
  '33333333-3333-3333-3333-333333333333',
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  ARRAY['tires', 'battery'],
  'medium',
  'إطارين خلفيين بحاجة لتبديل، والبطارية قديمة.',
  92200,
  'pending',
  NOW() - INTERVAL '60 hours'  -- This one is also overdue
),

-- LOW URGENCY (4 reports)
(
  'MNT-TEST-007',
  '11111111-1111-1111-1111-111111111111',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  ARRAY['oil_change'],
  'low',
  'موعد تغيير الزيت الدوري. آخر تغيير كان قبل 5000 كم.',
  87700,
  'pending',
  NOW() - INTERVAL '12 hours'
),
(
  'MNT-TEST-008',
  '22222222-2222-2222-2222-222222222222',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  ARRAY['ac'],
  'low',
  'التكييف لا يبرد بشكل كافي. يحتاج شحن فريون.',
  45400,
  'completed',
  NOW() - INTERVAL '5 days'
),
(
  'MNT-TEST-009',
  '33333333-3333-3333-3333-333333333333',
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  ARRAY['lights'],
  'low',
  'الضوء الخلفي الأيسر لا يعمل.',
  92300,
  'pending',
  NOW() - INTERVAL '6 hours'
),
(
  'MNT-TEST-010',
  '11111111-1111-1111-1111-111111111111',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  ARRAY['fridge'],
  'low',
  'ثلاجة التبريد تصدر صوت عالي أثناء العمل.',
  87800,
  'pending',
  NOW() - INTERVAL '3 hours'
);

-- Also insert some test inspections with issues
INSERT INTO inspections (
  inspection_code, driver_id, vehicle_id, inspection_type,
  light_front, light_back, signal_right, signal_left, fridge_status,
  odometer_reading, submitted_at
) VALUES
(
  'INS-TEST-001',
  '11111111-1111-1111-1111-111111111111',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'receive',
  true, false, true, true, 'working',  -- Back light not working
  87500,
  NOW() - INTERVAL '1 day'
),
(
  'INS-TEST-002',
  '22222222-2222-2222-2222-222222222222',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'receive',
  true, true, false, false, 'not_working',  -- Both signals + fridge not working
  45200,
  NOW() - INTERVAL '12 hours'
),
(
  'INS-TEST-003',
  '33333333-3333-3333-3333-333333333333',
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  'release',
  true, true, true, true, 'working',  -- All good
  92100,
  NOW() - INTERVAL '6 hours'
);

-- Summary of what was inserted
SELECT 'Test data inserted successfully!' as status;
SELECT 'Maintenance Reports: ' || COUNT(*) as count FROM maintenance_reports WHERE report_code LIKE 'MNT-TEST-%';
SELECT 'Inspections: ' || COUNT(*) as count FROM inspections WHERE inspection_code LIKE 'INS-TEST-%';
SELECT 'Test Drivers: ' || COUNT(*) as count FROM drivers WHERE driver_code LIKE 'DRV-TEST-%';
SELECT 'Test Vehicles: ' || COUNT(*) as count FROM vehicles WHERE van_code LIKE 'VAN-TEST-%';
