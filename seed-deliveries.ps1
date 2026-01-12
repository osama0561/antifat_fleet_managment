$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json; charset=utf-8"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SEEDING FOOD DELIVERIES DATA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Get driver IDs
$body = @{ query = "SELECT id, full_name FROM drivers WHERE is_active = true LIMIT 3;" } | ConvertTo-Json
$drivers = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body

if ($drivers.Count -eq 0) {
    Write-Host "No drivers found!" -ForegroundColor Red
    exit
}

$driverId1 = $drivers[0].id
$driverId2 = if ($drivers.Count -gt 1) { $drivers[1].id } else { $drivers[0].id }

Write-Host "Using drivers:" -ForegroundColor Gray
Write-Host "  Driver 1: $($drivers[0].full_name)" -ForegroundColor Gray
if ($drivers.Count -gt 1) { Write-Host "  Driver 2: $($drivers[1].full_name)" -ForegroundColor Gray }

Write-Host ""
Write-Host "Inserting food batches..." -ForegroundColor Magenta

# Insert batches one by one with SQL
$insertQueries = @(
    "INSERT INTO food_batches (batch_code, client_name, meal_count, delivered_count, status, delivery_location, kitchen_staff_id, driver_id, kitchen_signature, driver_signature, created_at, assigned_at, completed_at) VALUES ('BATCH-D001', 'King Fahd Hospital', 50, 50, 'completed', 'Jeddah - Rawdah', '$driverId1', '$driverId2', 'SIGNED:Kitchen', 'SIGNED:Driver', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day') ON CONFLICT (batch_code) DO UPDATE SET status = 'completed', delivered_count = 50;",
    "INSERT INTO food_batches (batch_code, client_name, meal_count, delivered_count, status, delivery_location, kitchen_staff_id, driver_id, kitchen_signature, driver_signature, created_at, assigned_at, completed_at) VALUES ('BATCH-D002', 'Aramco Company', 100, 100, 'completed', 'Dammam Industrial', '$driverId1', '$driverId2', 'SIGNED:Kitchen', 'SIGNED:Driver', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days') ON CONFLICT (batch_code) DO UPDATE SET status = 'completed', delivered_count = 100;",
    "INSERT INTO food_batches (batch_code, client_name, meal_count, delivered_count, status, delivery_location, kitchen_staff_id, driver_id, kitchen_signature, driver_signature, created_at, assigned_at, completed_at) VALUES ('BATCH-D003', 'Al-Faisal School', 30, 25, 'in_progress', 'Riyadh - Naseem', '$driverId1', '$driverId2', 'SIGNED:Kitchen', NULL, NOW(), NOW(), NULL) ON CONFLICT (batch_code) DO UPDATE SET status = 'in_progress', delivered_count = 25;",
    "INSERT INTO food_batches (batch_code, client_name, meal_count, delivered_count, status, delivery_location, kitchen_staff_id, driver_id, kitchen_signature, driver_signature, created_at, assigned_at, completed_at) VALUES ('BATCH-D004', 'Hilton Hotel', 75, 0, 'assigned', 'Jeddah Corniche', '$driverId1', '$driverId2', 'SIGNED:Kitchen', NULL, NOW(), NOW(), NULL) ON CONFLICT (batch_code) DO UPDATE SET status = 'assigned', delivered_count = 0;",
    "INSERT INTO food_batches (batch_code, client_name, meal_count, delivered_count, status, delivery_location, kitchen_staff_id, driver_id, kitchen_signature, driver_signature, created_at, assigned_at, completed_at) VALUES ('BATCH-D005', 'Almarai Factory', 200, 0, 'pending', 'Riyadh Industrial', '$driverId1', NULL, NULL, NULL, NOW(), NULL, NULL) ON CONFLICT (batch_code) DO UPDATE SET status = 'pending', delivered_count = 0;",
    "INSERT INTO food_batches (batch_code, client_name, meal_count, delivered_count, status, delivery_location, kitchen_staff_id, driver_id, kitchen_signature, driver_signature, created_at, assigned_at, completed_at) VALUES ('BATCH-D006', 'King Saud University', 150, 150, 'completed', 'Riyadh - Malaz', '$driverId1', '$driverId2', 'SIGNED:Kitchen', 'SIGNED:Driver', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days') ON CONFLICT (batch_code) DO UPDATE SET status = 'completed', delivered_count = 150;",
    "INSERT INTO food_batches (batch_code, client_name, meal_count, delivered_count, status, delivery_location, kitchen_staff_id, driver_id, kitchen_signature, driver_signature, created_at, assigned_at, completed_at) VALUES ('BATCH-D007', 'Mall of Arabia', 40, 0, 'pending', 'Jeddah Mall', '$driverId1', NULL, NULL, NULL, NOW(), NULL, NULL) ON CONFLICT (batch_code) DO UPDATE SET status = 'pending', delivered_count = 0;",
    "INSERT INTO food_batches (batch_code, client_name, meal_count, delivered_count, status, delivery_location, kitchen_staff_id, driver_id, kitchen_signature, driver_signature, created_at, assigned_at, completed_at) VALUES ('BATCH-D008', 'STC Company', 80, 80, 'completed', 'Riyadh - STC Tower', '$driverId1', '$driverId2', 'SIGNED:Kitchen', 'SIGNED:Driver', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days') ON CONFLICT (batch_code) DO UPDATE SET status = 'completed', delivered_count = 80;"
)

$batchNames = @(
    "BATCH-D001: King Fahd Hospital (completed)",
    "BATCH-D002: Aramco Company (completed)",
    "BATCH-D003: Al-Faisal School (in_progress)",
    "BATCH-D004: Hilton Hotel (assigned)",
    "BATCH-D005: Almarai Factory (pending)",
    "BATCH-D006: King Saud University (completed)",
    "BATCH-D007: Mall of Arabia (pending)",
    "BATCH-D008: STC Company (completed)"
)

for ($i = 0; $i -lt $insertQueries.Count; $i++) {
    $body = @{ query = $insertQueries[$i] } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
        Write-Host "  $($batchNames[$i])" -ForegroundColor Green
    } catch {
        Write-Host "  $($batchNames[$i]) - FAILED" -ForegroundColor Red
    }
}

# Final count
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DELIVERY COUNTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$body = @{ query = "SELECT status, COUNT(*) as cnt FROM food_batches GROUP BY status ORDER BY status;" } | ConvertTo-Json
$result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
Write-Host ""
$result | ForEach-Object { Write-Host "  $($_.status): $($_.cnt) batches" -ForegroundColor White }

$body = @{ query = "SELECT COUNT(*) as total FROM food_batches;" } | ConvertTo-Json
$total = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
Write-Host ""
Write-Host "  TOTAL: $($total[0].total) food batches" -ForegroundColor Cyan

Write-Host ""
Write-Host "DONE!" -ForegroundColor Green