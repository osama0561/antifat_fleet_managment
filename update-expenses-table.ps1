# Add company_paid and supervisor_name columns to expenses table

$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$sql = @"
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS company_paid BOOLEAN DEFAULT false;
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS supervisor_name VARCHAR(255);
ALTER TABLE expenses ALTER COLUMN supervisor_id DROP NOT NULL;
ALTER TABLE expenses ALTER COLUMN description DROP NOT NULL;
"@

$body = @{
    query = $sql
} | ConvertTo-Json

Write-Host "Adding company_paid and supervisor_name columns to expenses table..." -ForegroundColor Cyan

try {
    $mgmtHeaders = @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type" = "application/json"
    }

    $mgmtBody = @{
        query = $sql
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers $mgmtHeaders -Body $mgmtBody
    Write-Host "SUCCESS! Columns updated." -ForegroundColor Green
    Write-Host $response
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "You may need to run these SQL commands manually in Supabase Dashboard:" -ForegroundColor Yellow
    Write-Host $sql -ForegroundColor Cyan
}

Write-Host "`nDone!" -ForegroundColor Green
