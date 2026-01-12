# Run the license_photo migration via Supabase Management API

$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$sql = @"
ALTER TABLE accident_reports ADD COLUMN IF NOT EXISTS license_photo TEXT;
"@

$body = @{
    query = $sql
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers $headers -Body $body
    Write-Host "Migration successful!" -ForegroundColor Green
    Write-Host $response
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}