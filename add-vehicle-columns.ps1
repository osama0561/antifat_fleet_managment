$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ADDING VEHICLE COLUMNS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Add make column
Write-Host ""
Write-Host "Adding 'make' column..." -ForegroundColor Magenta

$sql1 = "ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS make VARCHAR(100);"
$body = @{ query = $sql1 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  make column added!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Error: $errorBody" -ForegroundColor Red
}

# Add model column
Write-Host ""
Write-Host "Adding 'model' column..." -ForegroundColor Magenta

$sql2 = "ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS model VARCHAR(100);"
$body = @{ query = $sql2 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  model column added!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Error: $errorBody" -ForegroundColor Red
}

# Add rental_company column
Write-Host ""
Write-Host "Adding 'rental_company' column..." -ForegroundColor Magenta

$sql3 = "ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS rental_company VARCHAR(255);"
$body = @{ query = $sql3 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  rental_company column added!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Error: $errorBody" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DONE! Columns added to vehicles table" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan