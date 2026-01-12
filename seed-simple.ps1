$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

# Get IDs
Write-Host "Getting existing IDs..." -ForegroundColor Cyan
$body = @{ query = "SELECT id FROM drivers WHERE is_active = true LIMIT 1;" } | ConvertTo-Json
$driverResult = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$driverId = $driverResult[0].id
Write-Host "Driver: $driverId" -ForegroundColor Green

$body = @{ query = "SELECT id FROM vehicles LIMIT 1;" } | ConvertTo-Json
$vehicleResult = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$vehicleId = $vehicleResult[0].id
Write-Host "Vehicle: $vehicleId" -ForegroundColor Green

Write-Host ""
Write-Host "Inserting inspections one by one..." -ForegroundColor Magenta

$inspections = @(
    @{ code = "INS-S001"; type = "receive"; lf = "true"; lb = "true"; sr = "true"; sl = "true"; fridge = "working"; notes = "Good condition" },
    @{ code = "INS-S002"; type = "release"; lf = "true"; lb = "true"; sr = "true"; sl = "true"; fridge = "working"; notes = "All OK" },
    @{ code = "INS-S003"; type = "receive"; lf = "true"; lb = "false"; sr = "true"; sl = "true"; fridge = "working"; notes = "Back light issue" },
    @{ code = "INS-S004"; type = "receive"; lf = "true"; lb = "true"; sr = "true"; sl = "true"; fridge = "not_working"; notes = "Fridge broken" },
    @{ code = "INS-S005"; type = "receive"; lf = "false"; lb = "true"; sr = "false"; sl = "true"; fridge = "not_working"; notes = "Multiple issues" },
    @{ code = "INS-S006"; type = "release"; lf = "true"; lb = "true"; sr = "false"; sl = "false"; fridge = "working"; notes = "Signals broken" },
    @{ code = "INS-S007"; type = "receive"; lf = "true"; lb = "true"; sr = "true"; sl = "true"; fridge = "no_fridge"; notes = "No fridge vehicle" },
    @{ code = "INS-S008"; type = "release"; lf = "true"; lb = "true"; sr = "true"; sl = "true"; fridge = "working"; notes = "Perfect" }
)

$count = 0
foreach ($insp in $inspections) {
    $sql = "INSERT INTO inspections (inspection_code, driver_id, vehicle_id, inspection_type, light_front, light_back, signal_right, signal_left, fridge_status, notes, declaration_accepted, submitted_at) VALUES ('$($insp.code)', '$driverId', '$vehicleId', '$($insp.type)', $($insp.lf), $($insp.lb), $($insp.sr), $($insp.sl), '$($insp.fridge)', '$($insp.notes)', true, NOW() - INTERVAL '$count days') ON CONFLICT (inspection_code) DO NOTHING;"

    $body = @{ query = $sql } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
        Write-Host "  $($insp.code): OK" -ForegroundColor Green
    } catch {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "  $($insp.code): FAILED - $errorBody" -ForegroundColor Red
    }
    $count++
}

Write-Host ""
Write-Host "Inserting accidents one by one..." -ForegroundColor Magenta

$accidents = @(
    @{ code = "ACC-S001"; type = "minor"; desc = "Minor scratch on bumper"; loc = "Jeddah parking"; status = "pending" },
    @{ code = "ACC-S002"; type = "collision"; desc = "Rear collision"; loc = "Highway"; status = "in_progress" },
    @{ code = "ACC-S003"; type = "collision"; desc = "Side impact at intersection"; loc = "Riyadh"; status = "resolved" },
    @{ code = "ACC-S004"; type = "rollover"; desc = "Rollover accident"; loc = "Desert road"; status = "in_progress" },
    @{ code = "ACC-S005"; type = "minor"; desc = "Shopping cart damage"; loc = "Supermarket"; status = "resolved" }
)

$count = 0
foreach ($acc in $accidents) {
    $sql = "INSERT INTO accident_reports (report_code, driver_id, vehicle_id, accident_type, description, accident_location, status, submitted_at) VALUES ('$($acc.code)', '$driverId', '$vehicleId', '$($acc.type)', '$($acc.desc)', '$($acc.loc)', '$($acc.status)', NOW() - INTERVAL '$count days') ON CONFLICT (report_code) DO NOTHING;"

    $body = @{ query = $sql } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
        Write-Host "  $($acc.code): OK" -ForegroundColor Green
    } catch {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "  $($acc.code): FAILED - $errorBody" -ForegroundColor Red
    }
    $count += 3
}

Write-Host ""
Write-Host "Final counts..." -ForegroundColor Cyan
$body = @{ query = "SELECT 'inspections' as tbl, COUNT(*) as cnt FROM inspections UNION ALL SELECT 'accidents', COUNT(*) FROM accident_reports;" } | ConvertTo-Json
$result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
$result | ForEach-Object { Write-Host "  $($_.tbl): $($_.cnt)" -ForegroundColor White }