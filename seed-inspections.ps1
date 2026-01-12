# Seed inspections using Supabase Management API

$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

Write-Host "Inserting test inspections..." -ForegroundColor Cyan

# Insert one at a time to find the issue
$sql1 = "INSERT INTO inspections (inspection_code, driver_id, vehicle_id, inspection_type, light_front, light_back, signal_right, signal_left, fridge_status, odometer_reading, submitted_at) VALUES ('INS-TEST-001', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'receive', true, false, true, true, 'working', 87500, NOW() - INTERVAL '1 day') ON CONFLICT DO NOTHING;"

$sql2 = "INSERT INTO inspections (inspection_code, driver_id, vehicle_id, inspection_type, light_front, light_back, signal_right, signal_left, fridge_status, odometer_reading, submitted_at) VALUES ('INS-TEST-002', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'receive', true, true, false, false, 'not_working', 45200, NOW() - INTERVAL '12 hours') ON CONFLICT DO NOTHING;"

$sql3 = "INSERT INTO inspections (inspection_code, driver_id, vehicle_id, inspection_type, light_front, light_back, signal_right, signal_left, fridge_status, odometer_reading, submitted_at) VALUES ('INS-TEST-003', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'release', true, true, true, true, 'working', 92100, NOW() - INTERVAL '6 hours') ON CONFLICT DO NOTHING;"

foreach ($sql in @($sql1, $sql2, $sql3)) {
    $body = @{ query = $sql } | ConvertTo-Json
    try {
        $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
        Write-Host "  OK" -ForegroundColor Green
    } catch {
        $errorResponse = $_.Exception.Response
        $reader = New-Object System.IO.StreamReader($errorResponse.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "  Error: $errorBody" -ForegroundColor Red
    }
}

# Also let's check the count
Write-Host ""
Write-Host "Checking counts..." -ForegroundColor Cyan

$countSQL = "SELECT 'maintenance_reports' as tbl, COUNT(*) as cnt FROM maintenance_reports WHERE report_code LIKE 'MNT-TEST-%' UNION ALL SELECT 'inspections', COUNT(*) FROM inspections WHERE inspection_code LIKE 'INS-TEST-%' UNION ALL SELECT 'drivers', COUNT(*) FROM drivers WHERE driver_code LIKE 'DRV-TEST-%' UNION ALL SELECT 'vehicles', COUNT(*) FROM vehicles WHERE van_code LIKE 'VAN-TEST-%';"

$body = @{ query = $countSQL } | ConvertTo-Json
try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
    $result | ForEach-Object { Write-Host "  $($_.tbl): $($_.cnt)" -ForegroundColor White }
} catch {
    Write-Host "  Could not get counts" -ForegroundColor Yellow
}
