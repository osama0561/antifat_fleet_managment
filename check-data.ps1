$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

Write-Host "=== DRIVERS ===" -ForegroundColor Cyan
$sql = "SELECT id, full_name, driver_code, email, role FROM drivers WHERE is_active = true ORDER BY role, full_name LIMIT 20;"
$body = @{ query = $sql } | ConvertTo-Json
$result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$result | Format-Table -AutoSize

Write-Host ""
Write-Host "=== VEHICLES ===" -ForegroundColor Cyan
$sql = "SELECT id, van_code, plate_number, status FROM vehicles ORDER BY van_code LIMIT 20;"
$body = @{ query = $sql } | ConvertTo-Json
$result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$result | Format-Table -AutoSize

Write-Host ""
Write-Host "=== CURRENT ASSIGNMENTS ===" -ForegroundColor Cyan
$sql = "SELECT d.full_name, d.driver_code, v.van_code, a.is_current FROM driver_vehicle_assignments a JOIN drivers d ON d.id = a.driver_id JOIN vehicles v ON v.id = a.vehicle_id WHERE a.is_current = true ORDER BY d.full_name;"
$body = @{ query = $sql } | ConvertTo-Json
$result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$result | Format-Table -AutoSize
