$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

# Check existing accident to see allowed values
Write-Host "Checking existing accident data..." -ForegroundColor Cyan
$body = @{ query = "SELECT * FROM accident_reports LIMIT 1;" } | ConvertTo-Json
$result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$result | Format-List

# Check constraint
Write-Host ""
Write-Host "Checking status constraint..." -ForegroundColor Cyan
$body = @{ query = "SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid = 'accident_reports'::regclass;" } | ConvertTo-Json
try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
    $result | Format-Table -AutoSize
} catch {
    Write-Host "Could not get constraints"
}

# Get driver/vehicle
$body = @{ query = "SELECT id FROM drivers WHERE is_active = true LIMIT 1;" } | ConvertTo-Json
$driverResult = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$driverId = $driverResult[0].id

$body = @{ query = "SELECT id FROM vehicles LIMIT 1;" } | ConvertTo-Json
$vehicleResult = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$vehicleId = $vehicleResult[0].id

# Try with correct status values
Write-Host ""
Write-Host "Trying accidents with different status values..." -ForegroundColor Magenta

$testCases = @(
    @{ status = "pending"; type = "minor" },
    @{ status = "in_progress"; type = "collision" },
    @{ status = "resolved"; type = "rollover" },
    @{ status = "submitted"; type = "minor" },
    @{ status = "reviewing"; type = "collision" }
)

foreach ($test in $testCases) {
    $sql = "INSERT INTO accident_reports (report_code, driver_id, vehicle_id, accident_type, description, accident_location, status, submitted_at) VALUES ('ACC-TEST-$($test.status)', '$driverId', '$vehicleId', '$($test.type)', 'Test', 'Test loc', '$($test.status)', NOW()) ON CONFLICT (report_code) DO NOTHING RETURNING id;"
    $body = @{ query = $sql } | ConvertTo-Json
    try {
        $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
        Write-Host "  status='$($test.status)': OK" -ForegroundColor Green
    } catch {
        Write-Host "  status='$($test.status)': FAILED" -ForegroundColor Red
    }
}

# Final count
Write-Host ""
$body = @{ query = "SELECT COUNT(*) as cnt FROM accident_reports;" } | ConvertTo-Json
$result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
Write-Host "Total accidents: $($result[0].cnt)" -ForegroundColor Cyan