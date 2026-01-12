# Seed maintenance data using Supabase Management API
# This bypasses RLS by running SQL directly

$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

Write-Host "Inserting maintenance reports via Management API..." -ForegroundColor Cyan

$maintenanceSQL = @"
INSERT INTO maintenance_reports (report_code, driver_id, vehicle_id, issue_types, urgency, description, odometer_reading, status, submitted_at)
VALUES
('MNT-TEST-001', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', ARRAY['brakes'], 'high', 'Brake noise urgent', 87500, 'pending', NOW() - INTERVAL '2 hours'),
('MNT-TEST-002', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', ARRAY['engine'], 'high', 'Engine clicking noise', 45200, 'pending', NOW() - INTERVAL '5 hours'),
('MNT-TEST-003', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', ARRAY['engine', 'brakes'], 'high', 'Brakes and engine - OVERDUE', 92100, 'pending', NOW() - INTERVAL '50 hours'),
('MNT-TEST-004', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', ARRAY['tires'], 'medium', 'Tire replacement', 87600, 'pending', NOW() - INTERVAL '1 day'),
('MNT-TEST-005', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', ARRAY['battery'], 'medium', 'Battery weak', 45300, 'in_progress', NOW() - INTERVAL '3 days'),
('MNT-TEST-006', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', ARRAY['tires', 'battery'], 'medium', 'Tires and battery - OVERDUE', 92200, 'pending', NOW() - INTERVAL '60 hours'),
('MNT-TEST-007', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', ARRAY['oil_change'], 'low', 'Oil change due', 87700, 'pending', NOW() - INTERVAL '12 hours'),
('MNT-TEST-008', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', ARRAY['ac'], 'low', 'AC not cooling', 45400, 'completed', NOW() - INTERVAL '5 days'),
('MNT-TEST-009', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', ARRAY['lights'], 'low', 'Rear light out', 92300, 'pending', NOW() - INTERVAL '6 hours'),
('MNT-TEST-010', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', ARRAY['fridge'], 'low', 'Fridge noise', 87800, 'pending', NOW() - INTERVAL '3 hours')
ON CONFLICT (report_code) DO NOTHING;
"@

$body = @{ query = $maintenanceSQL } | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
    Write-Host "  Maintenance reports: OK" -ForegroundColor Green
} catch {
    Write-Host "  Maintenance reports: $($_.Exception.Message)" -ForegroundColor Red
}

# Insert inspections
Write-Host "Inserting inspections..." -ForegroundColor Cyan

$inspectionsSQL = @"
INSERT INTO inspections (inspection_code, driver_id, vehicle_id, inspection_type, light_front, light_back, signal_right, signal_left, fridge_status, odometer_reading, submitted_at)
VALUES
('INS-TEST-001', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'receive', true, false, true, true, 'working', 87500, NOW() - INTERVAL '1 day'),
('INS-TEST-002', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'receive', true, true, false, false, 'not_working', 45200, NOW() - INTERVAL '12 hours'),
('INS-TEST-003', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'release', true, true, true, true, 'working', 92100, NOW() - INTERVAL '6 hours')
ON CONFLICT (inspection_code) DO NOTHING;
"@

$body = @{ query = $inspectionsSQL } | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
    Write-Host "  Inspections: OK" -ForegroundColor Green
} catch {
    Write-Host "  Inspections: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Done! Check your Supabase dashboard." -ForegroundColor Green
