$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

function Run-SQL($sql, $description) {
    Write-Host "  $description..." -ForegroundColor Yellow -NoNewline
    $body = @{ query = $sql } | ConvertTo-Json -Depth 10
    try {
        $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
        Write-Host " OK" -ForegroundColor Green
        return $result
    } catch {
        Write-Host " FAILED" -ForegroundColor Red
        return $null
    }
}

Write-Host ""
Write-Host "Checking existing data..." -ForegroundColor Cyan

# Check existing drivers
$result = Run-SQL "SELECT id, driver_code, full_name FROM drivers WHERE is_active = true LIMIT 5;" "Getting drivers"
if ($result) { $result | Format-Table -AutoSize }

# Check existing vehicles
$result = Run-SQL "SELECT id, van_code, plate_number FROM vehicles LIMIT 5;" "Getting vehicles"
if ($result) { $result | Format-Table -AutoSize }

Write-Host ""
Write-Host "Adding INSPECTIONS (using existing driver/vehicle IDs)..." -ForegroundColor Magenta

# Get first active driver and vehicle IDs
$driverResult = Run-SQL "SELECT id FROM drivers WHERE is_active = true LIMIT 1;" "Getting driver ID"
$vehicleResult = Run-SQL "SELECT id FROM vehicles LIMIT 1;" "Getting vehicle ID"

if ($driverResult -and $vehicleResult) {
    $driverId = $driverResult[0].id
    $vehicleId = $vehicleResult[0].id

    Write-Host "  Using driver: $driverId" -ForegroundColor Gray
    Write-Host "  Using vehicle: $vehicleId" -ForegroundColor Gray

    # Insert inspections
    $inspSQL = @"
INSERT INTO inspections (inspection_code, driver_id, vehicle_id, inspection_type, light_front, light_back, signal_right, signal_left, fridge_status, notes, declaration_accepted, submitted_at)
VALUES
('INS-SEED-001', '$driverId', '$vehicleId', 'receive', true, true, true, true, 'working', 'حالة ممتازة - فحص اختباري', true, NOW() - INTERVAL '2 days'),
('INS-SEED-002', '$driverId', '$vehicleId', 'release', true, true, true, true, 'working', NULL, true, NOW() - INTERVAL '2 days' + INTERVAL '8 hours'),
('INS-SEED-003', '$driverId', '$vehicleId', 'receive', true, false, true, true, 'working', 'الانوار الخلفية لا تعمل', true, NOW() - INTERVAL '3 days'),
('INS-SEED-004', '$driverId', '$vehicleId', 'receive', true, true, true, true, 'not_working', 'الثلاجة متعطلة', true, NOW() - INTERVAL '4 days'),
('INS-SEED-005', '$driverId', '$vehicleId', 'receive', false, true, false, true, 'not_working', 'مشاكل متعددة', true, NOW() - INTERVAL '5 days'),
('INS-SEED-006', '$driverId', '$vehicleId', 'release', true, true, false, false, 'working', 'اشارات لا تعمل', true, NOW() - INTERVAL '6 days'),
('INS-SEED-007', '$driverId', '$vehicleId', 'receive', true, true, true, true, 'no_fridge', 'بدون ثلاجة', true, NOW() - INTERVAL '7 days'),
('INS-SEED-008', '$driverId', '$vehicleId', 'release', true, true, true, true, 'working', 'حالة جيدة', true, NOW() - INTERVAL '8 days')
ON CONFLICT (inspection_code) DO NOTHING;
"@
    Run-SQL $inspSQL "Inserting 8 inspections"

    # Insert accidents
    Write-Host ""
    Write-Host "Adding ACCIDENTS..." -ForegroundColor Magenta

    $accSQL = @"
INSERT INTO accident_reports (report_code, driver_id, vehicle_id, accident_type, description, accident_location, status, submitted_at)
VALUES
('ACC-SEED-001', '$driverId', '$vehicleId', 'minor', 'اصطدام خفيف بالرصيف - خدش في الصدام', 'شارع الملك فهد - جدة', 'pending', NOW() - INTERVAL '2 days'),
('ACC-SEED-002', '$driverId', '$vehicleId', 'collision', 'سيارة اصطدمت من الخلف', 'طريق المدينة - جدة', 'in_progress', NOW() - INTERVAL '4 days'),
('ACC-SEED-003', '$driverId', '$vehicleId', 'collision', 'تصادم في تقاطع', 'تقاطع الاربعين - الرياض', 'resolved', NOW() - INTERVAL '7 days'),
('ACC-SEED-004', '$driverId', '$vehicleId', 'rollover', 'حادث انقلاب - اضرار جسيمة', 'طريق الدائري', 'in_progress', NOW() - INTERVAL '9 days'),
('ACC-SEED-005', '$driverId', '$vehicleId', 'minor', 'خدش في الموقف', 'موقف سوبرماركت', 'resolved', NOW() - INTERVAL '15 days')
ON CONFLICT (report_code) DO NOTHING;
"@
    Run-SQL $accSQL "Inserting 5 accidents"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FINAL COUNTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$countSQL = @"
SELECT 'drivers' as tbl, COUNT(*) as cnt FROM drivers
UNION ALL SELECT 'vehicles', COUNT(*) FROM vehicles
UNION ALL SELECT 'inspections', COUNT(*) FROM inspections
UNION ALL SELECT 'maintenance', COUNT(*) FROM maintenance_reports
UNION ALL SELECT 'accidents', COUNT(*) FROM accident_reports;
"@

$result = Run-SQL $countSQL "Getting counts"
if ($result) {
    Write-Host ""
    $result | ForEach-Object {
        Write-Host "  $($_.tbl): $($_.cnt) records" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "DONE!" -ForegroundColor Green