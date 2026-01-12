$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

Write-Host "1. Finding driver@antifat.com..." -ForegroundColor Yellow
$sql = "SELECT id, full_name, driver_code FROM drivers WHERE email = 'driver@antifat.com';"
$body = @{ query = $sql } | ConvertTo-Json
$result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$result | Format-Table -AutoSize

Write-Host "2. Available vehicles..." -ForegroundColor Yellow
$sql = "SELECT id, van_code, plate_number, status FROM vehicles LIMIT 10;"
$body = @{ query = $sql } | ConvertTo-Json
$result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$result | Format-Table -AutoSize

Write-Host "3. Assigning driver@antifat.com to VAN-TEST-001..." -ForegroundColor Yellow
$sql = @"
INSERT INTO driver_vehicle_assignments (driver_id, vehicle_id, is_current)
SELECT
    (SELECT id FROM drivers WHERE email = 'driver@antifat.com'),
    (SELECT id FROM vehicles WHERE van_code = 'VAN-TEST-001'),
    true
ON CONFLICT DO NOTHING;
"@
$body = @{ query = $sql } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
    Write-Host "   Assignment created!" -ForegroundColor Green
} catch {
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Verifying assignment..." -ForegroundColor Yellow
$sql = @"
SELECT d.full_name, d.email, d.driver_code, v.van_code, v.plate_number, a.is_current
FROM driver_vehicle_assignments a
JOIN drivers d ON d.id = a.driver_id
JOIN vehicles v ON v.id = a.vehicle_id
WHERE d.email = 'driver@antifat.com' AND a.is_current = true;
"@
$body = @{ query = $sql } | ConvertTo-Json
$result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$result | Format-Table -AutoSize
