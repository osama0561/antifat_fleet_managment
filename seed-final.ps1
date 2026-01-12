$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

# Get IDs
$body = @{ query = "SELECT id FROM drivers WHERE is_active = true LIMIT 1;" } | ConvertTo-Json
$driverResult = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$driverId = $driverResult[0].id

$body = @{ query = "SELECT id FROM vehicles LIMIT 1;" } | ConvertTo-Json
$vehicleResult = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$vehicleId = $vehicleResult[0].id

Write-Host "Inserting accidents with correct values..." -ForegroundColor Magenta
Write-Host "  Driver: $driverId" -ForegroundColor Gray
Write-Host "  Vehicle: $vehicleId" -ForegroundColor Gray

# Correct values: status = pending, under_investigation, resolved
# accident_type = collision, scratch, rollover

$accidents = @(
    @{ code = "ACC-F001"; type = "scratch"; desc = "Minor scratch on bumper"; loc = "Jeddah parking"; status = "pending" },
    @{ code = "ACC-F002"; type = "collision"; desc = "Rear collision on highway"; loc = "Highway exit"; status = "under_investigation" },
    @{ code = "ACC-F003"; type = "collision"; desc = "Side impact at intersection"; loc = "Riyadh center"; status = "resolved" },
    @{ code = "ACC-F004"; type = "rollover"; desc = "Rollover due to road hazard"; loc = "Desert road"; status = "under_investigation" },
    @{ code = "ACC-F005"; type = "scratch"; desc = "Shopping cart damage"; loc = "Supermarket lot"; status = "resolved" }
)

foreach ($acc in $accidents) {
    $sql = "INSERT INTO accident_reports (report_code, driver_id, vehicle_id, accident_type, description, accident_location, status, submitted_at) VALUES ('$($acc.code)', '$driverId', '$vehicleId', '$($acc.type)', '$($acc.desc)', '$($acc.loc)', '$($acc.status)', NOW() - INTERVAL '$(Get-Random -Minimum 1 -Maximum 15) days') ON CONFLICT (report_code) DO NOTHING;"
    $body = @{ query = $sql } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
        Write-Host "  $($acc.code): OK" -ForegroundColor Green
    } catch {
        Write-Host "  $($acc.code): FAILED" -ForegroundColor Red
    }
}

# Final counts
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FINAL COUNTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$body = @{ query = @"
SELECT 'drivers' as tbl, COUNT(*) as cnt FROM drivers
UNION ALL SELECT 'vehicles', COUNT(*) FROM vehicles
UNION ALL SELECT 'inspections', COUNT(*) FROM inspections
UNION ALL SELECT 'maintenance', COUNT(*) FROM maintenance_reports
UNION ALL SELECT 'accidents', COUNT(*) FROM accident_reports;
"@ } | ConvertTo-Json

$result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
Write-Host ""
$result | ForEach-Object { Write-Host "  $($_.tbl): $($_.cnt) records" -ForegroundColor White }

Write-Host ""
Write-Host "DONE!" -ForegroundColor Green