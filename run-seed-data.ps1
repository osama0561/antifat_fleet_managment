
# FleetCheck - Seed Test Data Script
# This script inserts 10 test maintenance records into Supabase

$headers = @{
    'Authorization' = 'Bearer sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa'
    'Content-Type' = 'application/json'
}

$baseUrl = 'https://api.supabase.com/v1/projects/fwatvgxueajvjcwdokwh/database/query'

Write-Host "=== FleetCheck Test Data Seeder ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Insert test drivers
Write-Host "1. Inserting test drivers..." -ForegroundColor Yellow
$driversQuery = @{
    query = @"
INSERT INTO drivers (id, email, full_name, driver_code, phone, role, is_active, driver_type)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'test.driver1@antifat.com', 'Ahmed Test Driver', 'DRV-TEST-001', '+966501234567', 'driver', true, 'permanent'),
  ('22222222-2222-2222-2222-222222222222', 'test.driver2@antifat.com', 'Fatima Test Driver', 'DRV-TEST-002', '+966502345678', 'driver', true, 'permanent'),
  ('33333333-3333-3333-3333-333333333333', 'test.driver3@antifat.com', 'Mohammed Test Driver', 'DRV-TEST-003', '+966503456789', 'driver', true, 'permanent')
ON CONFLICT (email) DO NOTHING;
"@
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $driversQuery
    Write-Host "   Drivers: OK" -ForegroundColor Green
} catch {
    Write-Host "   Drivers: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 2: Insert test vehicles
Write-Host "2. Inserting test vehicles..." -ForegroundColor Yellow
$vehiclesQuery = @{
    query = @"
INSERT INTO vehicles (id, van_code, plate_number, status, location, registration_expiry, insurance_expiry)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'VAN-TEST-001', 'ABC 1234', 'active', 'Jeddah', CURRENT_DATE + INTERVAL '60 days', CURRENT_DATE + INTERVAL '90 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'VAN-TEST-002', 'DEF 5678', 'active', 'Riyadh', CURRENT_DATE + INTERVAL '15 days', CURRENT_DATE + INTERVAL '20 days'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'VAN-TEST-003', 'GHI 9012', 'idle', 'Jeddah', CURRENT_DATE + INTERVAL '5 days', CURRENT_DATE + INTERVAL '10 days')
ON CONFLICT (van_code) DO NOTHING;
"@
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $vehiclesQuery
    Write-Host "   Vehicles: OK" -ForegroundColor Green
} catch {
    Write-Host "   Vehicles: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Insert driver-vehicle assignments
Write-Host "3. Inserting driver-vehicle assignments..." -ForegroundColor Yellow
$assignmentsQuery = @{
    query = @"
INSERT INTO driver_vehicle_assignments (driver_id, vehicle_id, is_current)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true),
  ('22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', true),
  ('33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', true)
ON CONFLICT DO NOTHING;
"@
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $assignmentsQuery
    Write-Host "   Assignments: OK" -ForegroundColor Green
} catch {
    Write-Host "   Assignments: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Insert 10 maintenance reports
Write-Host "4. Inserting 10 test maintenance reports..." -ForegroundColor Yellow
$maintenanceQuery = @{
    query = @"
INSERT INTO maintenance_reports (
  report_code, driver_id, vehicle_id, issue_types, urgency, description,
  odometer_reading, status, submitted_at
) VALUES
-- HIGH URGENCY
('MNT-TEST-001', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', ARRAY['brakes'], 'high', 'Brake noise when pressing pedal. Needs urgent check.', 87500, 'pending', NOW() - INTERVAL '2 hours'),
('MNT-TEST-002', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', ARRAY['engine'], 'high', 'Engine making clicking noise on startup. Check engine light on.', 45200, 'pending', NOW() - INTERVAL '5 hours'),
('MNT-TEST-003', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', ARRAY['engine', 'brakes'], 'high', 'Brakes not responsive and engine overheating.', 92100, 'pending', NOW() - INTERVAL '50 hours'),
-- MEDIUM URGENCY
('MNT-TEST-004', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', ARRAY['tires'], 'medium', 'Front left tire needs replacement. Tread worn out.', 87600, 'pending', NOW() - INTERVAL '1 day'),
('MNT-TEST-005', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', ARRAY['battery'], 'medium', 'Battery weak. Vehicle takes long to start in morning.', 45300, 'in_progress', NOW() - INTERVAL '3 days'),
('MNT-TEST-006', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', ARRAY['tires', 'battery'], 'medium', 'Two rear tires need replacement and battery is old.', 92200, 'pending', NOW() - INTERVAL '60 hours'),
-- LOW URGENCY
('MNT-TEST-007', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', ARRAY['oil_change'], 'low', 'Regular oil change due. Last change was 5000km ago.', 87700, 'pending', NOW() - INTERVAL '12 hours'),
('MNT-TEST-008', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', ARRAY['ac'], 'low', 'AC not cooling enough. Needs freon recharge.', 45400, 'completed', NOW() - INTERVAL '5 days'),
('MNT-TEST-009', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', ARRAY['lights'], 'low', 'Left rear light not working.', 92300, 'pending', NOW() - INTERVAL '6 hours'),
('MNT-TEST-010', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', ARRAY['fridge'], 'low', 'Fridge making loud noise during operation.', 87800, 'pending', NOW() - INTERVAL '3 hours')
ON CONFLICT (report_code) DO NOTHING;
"@
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $maintenanceQuery
    Write-Host "   Maintenance Reports: OK" -ForegroundColor Green
} catch {
    Write-Host "   Maintenance Reports: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 5: Insert test inspections
Write-Host "5. Inserting test inspections with issues..." -ForegroundColor Yellow
$inspectionsQuery = @{
    query = @"
INSERT INTO inspections (
  inspection_code, driver_id, vehicle_id, inspection_type,
  light_front, light_back, signal_right, signal_left, fridge_status,
  odometer_reading, submitted_at
) VALUES
('INS-TEST-001', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'receive', true, false, true, true, 'working', 87500, NOW() - INTERVAL '1 day'),
('INS-TEST-002', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'receive', true, true, false, false, 'not_working', 45200, NOW() - INTERVAL '12 hours'),
('INS-TEST-003', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'release', true, true, true, true, 'working', 92100, NOW() - INTERVAL '6 hours')
ON CONFLICT (inspection_code) DO NOTHING;
"@
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $inspectionsQuery
    Write-Host "   Inspections: OK" -ForegroundColor Green
} catch {
    Write-Host "   Inspections: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Seed Data Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Created:" -ForegroundColor White
Write-Host "  - 3 Test Drivers (DRV-TEST-001, 002, 003)" -ForegroundColor Gray
Write-Host "  - 3 Test Vehicles (VAN-TEST-001, 002, 003)" -ForegroundColor Gray
Write-Host "  - 10 Maintenance Reports (MNT-TEST-001 to 010)" -ForegroundColor Gray
Write-Host "  - 3 Inspections with issues (INS-TEST-001, 002, 003)" -ForegroundColor Gray
Write-Host ""
Write-Host "To delete test data later, run:" -ForegroundColor Yellow
Write-Host "  DELETE FROM maintenance_reports WHERE report_code LIKE 'MNT-TEST-%';" -ForegroundColor Gray
Write-Host "  DELETE FROM inspections WHERE inspection_code LIKE 'INS-TEST-%';" -ForegroundColor Gray
Write-Host "  DELETE FROM driver_vehicle_assignments WHERE driver_id IN (SELECT id FROM drivers WHERE driver_code LIKE 'DRV-TEST-%');" -ForegroundColor Gray
Write-Host "  DELETE FROM drivers WHERE driver_code LIKE 'DRV-TEST-%';" -ForegroundColor Gray
Write-Host "  DELETE FROM vehicles WHERE van_code LIKE 'VAN-TEST-%';" -ForegroundColor Gray
