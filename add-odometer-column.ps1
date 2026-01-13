# Add odometer_reading column to inspections table

$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$sql = @"
ALTER TABLE inspections ADD COLUMN IF NOT EXISTS odometer_reading INTEGER;
"@

$body = @{
    query = $sql
} | ConvertTo-Json

Write-Host "Adding odometer_reading column to inspections table..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "https://$projectRef.supabase.co/rest/v1/rpc/exec_sql" -Method POST -Headers $headers -Body $body
    Write-Host "Response: $response" -ForegroundColor Yellow
} catch {
    Write-Host "Direct RPC failed, trying Management API..." -ForegroundColor Yellow

    $mgmtHeaders = @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type" = "application/json"
    }

    $mgmtBody = @{
        query = $sql
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers $mgmtHeaders -Body $mgmtBody
        Write-Host "SUCCESS! Column added." -ForegroundColor Green
        Write-Host $response
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        Write-Host "You may need to add this column manually in Supabase Dashboard:" -ForegroundColor Yellow
        Write-Host "ALTER TABLE inspections ADD COLUMN IF NOT EXISTS odometer_reading INTEGER;" -ForegroundColor Cyan
    }
}

Write-Host "`nDone!" -ForegroundColor Green
