$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

function Run-SQL($sql, $description) {
    Write-Host "  $description..." -ForegroundColor Yellow -NoNewline
    $body = @{ query = $sql } | ConvertTo-Json
    try {
        $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
        Write-Host " OK" -ForegroundColor Green
        return $true
    } catch {
        $errorResponse = $_.Exception.Response
        if ($errorResponse) {
            $reader = New-Object System.IO.StreamReader($errorResponse.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            Write-Host " FAILED" -ForegroundColor Red
            Write-Host "    Error: $errorBody" -ForegroundColor DarkRed
        } else {
            Write-Host " FAILED: $($_.Exception.Message)" -ForegroundColor Red
        }
        return $false
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SEEDING TEST DATA - ALL TABLES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 1. DRIVERS (8 drivers - mix of roles/status)
# ============================================
Write-Host "1. DRIVERS (8 records)" -ForegroundColor Magenta

$driverSQL = @"
INSERT INTO drivers (id, full_name, driver_code, email, phone, role, is_active, license_expiry, id_expiry, location, created_at)
VALUES
('d1111111-1111-1111-1111-111111111111', 'احمد الفهد', 'DRV-001', 'ahmed@antifat.com', '+966501234567', 'driver', true, '2025-06-15', '2026-01-20', 'Jeddah', NOW() - INTERVAL '60 days'),
('d2222222-2222-2222-2222-222222222222', 'محمد السعيد', 'DRV-002', 'mohammed@antifat.com', '+966502345678', 'driver', true, '2025-03-20', '2025-08-15', 'Jeddah', NOW() - INTERVAL '45 days'),
('d3333333-3333-3333-3333-333333333333', 'خالد العتيبي', 'DRV-003', 'khaled@antifat.com', '+966503456789', 'driver', true, '2024-12-01', '2025-05-10', 'Riyadh', NOW() - INTERVAL '30 days'),
('d4444444-4444-4444-4444-444444444444', 'فهد الدوسري', 'DRV-004', 'fahad@antifat.com', '+966504567890', 'driver', true, '2025-08-10', '2026-03-25', 'Riyadh', NOW() - INTERVAL '20 days'),
('d5555555-5555-5555-5555-555555555555', 'سعود المالكي', 'DRV-005', 'saud@antifat.com', '+966505678901', 'driver', true, '2025-01-05', '2025-06-30', 'Riyadh', NOW() - INTERVAL '15 days'),
('d6666666-6666-6666-6666-666666666666', 'عبدالله القحطاني', 'DRV-006', 'abdullah@antifat.com', '+966506789012', 'driver', false, '2025-04-30', '2025-09-15', 'Jeddah', NOW() - INTERVAL '90 days'),
('d7777777-7777-7777-7777-777777777777', 'ناصر الشمري', 'SUP-001', 'nasser@antifat.com', '+966507890123', 'supervisor', true, '2025-11-20', '2026-05-10', 'Jeddah', NOW() - INTERVAL '120 days'),
('d8888888-8888-8888-8888-888888888888', 'عمر المطيري', 'ADM-001', 'omar@antifat.com', '+966508901234', 'admin', true, NULL, NULL, 'Riyadh', NOW() - INTERVAL '180 days')
ON CONFLICT (id) DO NOTHING;
"@
Run-SQL $driverSQL "Inserting 8 drivers"

# ============================================
# 2. VEHICLES (7 vehicles - mix of status)
# ============================================
Write-Host ""
Write-Host "2. VEHICLES (7 records)" -ForegroundColor Magenta

$vehicleSQL = @"
INSERT INTO vehicles (id, van_code, plate_number, status, location, insurance_expiry, registration_expiry, is_active, created_at)
VALUES
('v1111111-1111-1111-1111-111111111111', 'VAN-JED-01', 'ABC 1234', 'active', 'Jeddah', '2025-06-30', '2025-08-15', true, NOW() - INTERVAL '200 days'),
('v2222222-2222-2222-2222-222222222222', 'VAN-JED-02', 'DEF 5678', 'active', 'Jeddah', '2025-04-15', '2025-05-20', true, NOW() - INTERVAL '180 days'),
('v3333333-3333-3333-3333-333333333333', 'VAN-RYD-01', 'GHI 9012', 'active', 'Riyadh', '2025-09-01', '2025-10-10', true, NOW() - INTERVAL '90 days'),
('v4444444-4444-4444-4444-444444444444', 'VAN-RYD-02', 'JKL 3456', 'idle', 'Riyadh', '2025-02-28', '2025-03-15', true, NOW() - INTERVAL '250 days'),
('v5555555-5555-5555-5555-555555555555', 'VAN-JED-03', 'MNO 7890', 'maintenance', 'Jeddah', '2025-07-20', '2025-09-05', true, NOW() - INTERVAL '150 days'),
('v6666666-6666-6666-6666-666666666666', 'VAN-RYD-03', 'PQR 2345', 'active', 'Riyadh', '2025-05-10', '2025-06-25', true, NOW() - INTERVAL '160 days'),
('v7777777-7777-7777-7777-777777777777', 'VAN-JED-04', 'STU 6789', 'idle', 'Jeddah', '2024-11-30', '2024-12-15', false, NOW() - INTERVAL '300 days')
ON CONFLICT (id) DO NOTHING;
"@
Run-SQL $vehicleSQL "Inserting 7 vehicles"

# ============================================
# 3. DRIVER-VEHICLE ASSIGNMENTS
# ============================================
Write-Host ""
Write-Host "3. ASSIGNMENTS (5 records)" -ForegroundColor Magenta

$assignSQL = @"
INSERT INTO driver_vehicle_assignments (driver_id, vehicle_id, is_current, assigned_at)
VALUES
('d1111111-1111-1111-1111-111111111111', 'v1111111-1111-1111-1111-111111111111', true, NOW() - INTERVAL '30 days'),
('d2222222-2222-2222-2222-222222222222', 'v2222222-2222-2222-2222-222222222222', true, NOW() - INTERVAL '25 days'),
('d3333333-3333-3333-3333-333333333333', 'v3333333-3333-3333-3333-333333333333', true, NOW() - INTERVAL '20 days'),
('d4444444-4444-4444-4444-444444444444', 'v4444444-4444-4444-4444-444444444444', true, NOW() - INTERVAL '15 days'),
('d5555555-5555-5555-5555-555555555555', 'v6666666-6666-6666-6666-666666666666', true, NOW() - INTERVAL '10 days')
ON CONFLICT DO NOTHING;
"@
Run-SQL $assignSQL "Inserting 5 assignments"

# ============================================
# 4. INSPECTIONS (8 records - mix of types/issues)
# ============================================
Write-Host ""
Write-Host "4. INSPECTIONS (8 records)" -ForegroundColor Magenta

$inspSQL = @"
INSERT INTO inspections (inspection_code, driver_id, vehicle_id, inspection_type, light_front, light_back, signal_right, signal_left, fridge_status, notes, declaration_accepted, submitted_at)
VALUES
('INS-20250110-001', 'd1111111-1111-1111-1111-111111111111', 'v1111111-1111-1111-1111-111111111111', 'receive', true, true, true, true, 'working', 'حالة ممتازة', true, NOW() - INTERVAL '2 days'),
('INS-20250110-002', 'd1111111-1111-1111-1111-111111111111', 'v1111111-1111-1111-1111-111111111111', 'release', true, true, true, true, 'working', NULL, true, NOW() - INTERVAL '2 days' + INTERVAL '8 hours'),
('INS-20250109-001', 'd2222222-2222-2222-2222-222222222222', 'v2222222-2222-2222-2222-222222222222', 'receive', true, false, true, true, 'working', 'الانوار الخلفية لا تعمل', true, NOW() - INTERVAL '3 days'),
('INS-20250108-001', 'd3333333-3333-3333-3333-333333333333', 'v3333333-3333-3333-3333-333333333333', 'receive', true, true, true, true, 'not_working', 'الثلاجة متعطلة - تحتاج صيانة فورية', true, NOW() - INTERVAL '4 days'),
('INS-20250107-001', 'd4444444-4444-4444-4444-444444444444', 'v4444444-4444-4444-4444-444444444444', 'receive', false, true, false, true, 'not_working', 'مشاكل متعددة في الاضاءة والتبريد', true, NOW() - INTERVAL '5 days'),
('INS-20250106-001', 'd5555555-5555-5555-5555-555555555555', 'v6666666-6666-6666-6666-666666666666', 'receive', true, true, true, true, 'no_fridge', 'سيارة نقل عادية بدون ثلاجة', true, NOW() - INTERVAL '6 days'),
('INS-20250105-001', 'd2222222-2222-2222-2222-222222222222', 'v2222222-2222-2222-2222-222222222222', 'release', true, true, false, false, 'working', 'اشارات الانعطاف لا تعمل', true, NOW() - INTERVAL '7 days'),
('INS-20250104-001', 'd3333333-3333-3333-3333-333333333333', 'v3333333-3333-3333-3333-333333333333', 'release', true, true, true, true, 'working', NULL, true, NOW() - INTERVAL '8 days')
ON CONFLICT (inspection_code) DO NOTHING;
"@
Run-SQL $inspSQL "Inserting 8 inspections"

# ============================================
# 5. MAINTENANCE REPORTS (9 records - various urgency/status)
# ============================================
Write-Host ""
Write-Host "5. MAINTENANCE REPORTS (9 records)" -ForegroundColor Magenta

$maintSQL = @"
INSERT INTO maintenance_reports (report_code, driver_id, vehicle_id, issue_types, urgency, description, odometer_reading, status, submitted_at, resolved_at)
VALUES
('MNT-20250112-001', 'd1111111-1111-1111-1111-111111111111', 'v1111111-1111-1111-1111-111111111111', ARRAY['brakes'], 'high', 'صوت احتكاك في الفرامل عند الضغط', 52400, 'pending', NOW() - INTERVAL '5 hours', NULL),
('MNT-20250111-001', 'd2222222-2222-2222-2222-222222222222', 'v2222222-2222-2222-2222-222222222222', ARRAY['engine'], 'high', 'صوت طقطقة من المحرك', 85700, 'in_progress', NOW() - INTERVAL '1 day', NULL),
('MNT-20250108-001', 'd3333333-3333-3333-3333-333333333333', 'v3333333-3333-3333-3333-333333333333', ARRAY['fridge'], 'high', 'الثلاجة لا تبرد - طعام يفسد', 18550, 'pending', NOW() - INTERVAL '4 days', NULL),
('MNT-20250110-001', 'd4444444-4444-4444-4444-444444444444', 'v4444444-4444-4444-4444-444444444444', ARRAY['tires'], 'medium', 'اطار امامي يحتاج تبديل', 98750, 'pending', NOW() - INTERVAL '2 days', NULL),
('MNT-20250105-001', 'd5555555-5555-5555-5555-555555555555', 'v6666666-6666-6666-6666-666666666666', ARRAY['battery'], 'medium', 'البطارية ضعيفة', 46100, 'completed', NOW() - INTERVAL '7 days', NOW() - INTERVAL '5 days'),
('MNT-20250109-001', 'd1111111-1111-1111-1111-111111111111', 'v1111111-1111-1111-1111-111111111111', ARRAY['oil_change'], 'low', 'موعد تغيير الزيت قريب', 52300, 'pending', NOW() - INTERVAL '3 days', NULL),
('MNT-20250101-001', 'd2222222-2222-2222-2222-222222222222', 'v2222222-2222-2222-2222-222222222222', ARRAY['ac'], 'low', 'التكييف لا يبرد جيدا', 85500, 'completed', NOW() - INTERVAL '11 days', NOW() - INTERVAL '9 days'),
('MNT-20250107-001', 'd3333333-3333-3333-3333-333333333333', 'v5555555-5555-5555-5555-555555555555', ARRAY['lights', 'wipers'], 'medium', 'اضاءة خلفية + مساحات', 67800, 'in_progress', NOW() - INTERVAL '5 days', NULL),
('MNT-20250106-001', 'd4444444-4444-4444-4444-444444444444', 'v4444444-4444-4444-4444-444444444444', ARRAY['lights'], 'low', 'لمبة داخلية محترقة', 98600, 'pending', NOW() - INTERVAL '6 days', NULL)
ON CONFLICT (report_code) DO NOTHING;
"@
Run-SQL $maintSQL "Inserting 9 maintenance reports"

# ============================================
# 6. ACCIDENTS (5 records - various types)
# ============================================
Write-Host ""
Write-Host "6. ACCIDENTS (5 records)" -ForegroundColor Magenta

$accSQL = @"
INSERT INTO accident_reports (report_code, driver_id, vehicle_id, accident_type, description, accident_location, status, submitted_at)
VALUES
('ACC-20250110-001', 'd1111111-1111-1111-1111-111111111111', 'v1111111-1111-1111-1111-111111111111', 'minor', 'اصطدام خفيف بالرصيف اثناء الركن - خدش في الصدام الامامي', 'شارع الملك فهد - جدة', 'pending', NOW() - INTERVAL '2 days'),
('ACC-20250108-001', 'd2222222-2222-2222-2222-222222222222', 'v2222222-2222-2222-2222-222222222222', 'collision', 'سيارة اخرى اصطدمت من الخلف - صدام خلفي متضرر', 'طريق المدينة - جدة', 'in_progress', NOW() - INTERVAL '4 days'),
('ACC-20250105-001', 'd3333333-3333-3333-3333-333333333333', 'v3333333-3333-3333-3333-333333333333', 'collision', 'تصادم في تقاطع - باب جانبي وجناح امامي متضرر', 'تقاطع الاربعين - الرياض', 'resolved', NOW() - INTERVAL '7 days'),
('ACC-20250103-001', 'd4444444-4444-4444-4444-444444444444', 'v4444444-4444-4444-4444-444444444444', 'rollover', 'حادث انقلاب بسبب مطب غير واضح - اضرار جسيمة', 'طريق الدائري - الرياض', 'in_progress', NOW() - INTERVAL '9 days'),
('ACC-20241228-001', 'd5555555-5555-5555-5555-555555555555', 'v6666666-6666-6666-6666-666666666666', 'minor', 'خدش من عربة تسوق في الموقف', 'موقف سوبرماركت - الرياض', 'resolved', NOW() - INTERVAL '15 days')
ON CONFLICT (report_code) DO NOTHING;
"@
Run-SQL $accSQL "Inserting 5 accidents"

# ============================================
# SUMMARY
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$countSQL = @"
SELECT 'drivers' as tbl, COUNT(*) as cnt FROM drivers
UNION ALL SELECT 'vehicles', COUNT(*) FROM vehicles
UNION ALL SELECT 'assignments', COUNT(*) FROM driver_vehicle_assignments
UNION ALL SELECT 'inspections', COUNT(*) FROM inspections
UNION ALL SELECT 'maintenance', COUNT(*) FROM maintenance_reports
UNION ALL SELECT 'accidents', COUNT(*) FROM accident_reports;
"@

$body = @{ query = $countSQL } | ConvertTo-Json
try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
    Write-Host ""
    $result | ForEach-Object {
        Write-Host "  $($_.tbl): $($_.cnt) records" -ForegroundColor White
    }
} catch {
    Write-Host "  Could not verify counts" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  DONE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Note: food_deliveries and attendance tables" -ForegroundColor Yellow
Write-Host "      don't exist in your schema yet." -ForegroundColor Yellow
Write-Host ""