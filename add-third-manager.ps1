$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

Write-Host ""
Write-Host "Adding third manager (Mohammed Al-Jameh)..." -ForegroundColor Cyan

$insertSQL = @"
INSERT INTO supervisors (full_name, phone, region, initial_balance, current_balance, is_active)
VALUES ('محمد الجامح', '0555000003', 'JEDDAH', 50000, 50000, true)
ON CONFLICT DO NOTHING;
"@

$body = @{ query = $insertSQL } | ConvertTo-Json -Depth 10
try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
    Write-Host "Third manager added successfully!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "Error: $errorBody" -ForegroundColor Red
}
