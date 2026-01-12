$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

Write-Host "Adding video_url column to maintenance_reports..." -ForegroundColor Cyan

$sql = "ALTER TABLE maintenance_reports ADD COLUMN IF NOT EXISTS video_url TEXT;"
$body = @{ query = $sql } | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
    Write-Host "Column added successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Verify the column exists
Write-Host ""
Write-Host "Verifying column exists..." -ForegroundColor Cyan

$verifySql = "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'maintenance_reports' AND column_name = 'video_url';"
$body = @{ query = $verifySql } | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
    if ($result) {
        Write-Host "Verified: video_url column exists" -ForegroundColor Green
        $result | Format-Table -AutoSize
    } else {
        Write-Host "Column not found in verification" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Verification error: $($_.Exception.Message)" -ForegroundColor Yellow
}
