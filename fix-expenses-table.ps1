# Fix expenses table - change supervisor_id from UUID to VARCHAR

$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$sql = @"
-- Drop the foreign key constraint on supervisor_id
ALTER TABLE expenses DROP CONSTRAINT IF EXISTS expenses_supervisor_id_fkey;

-- Change supervisor_id from UUID to VARCHAR
ALTER TABLE expenses ALTER COLUMN supervisor_id TYPE VARCHAR(100) USING supervisor_id::VARCHAR;

-- Make sure driver_id can be null (in case driver lookup fails)
ALTER TABLE expenses ALTER COLUMN driver_id DROP NOT NULL;
"@

Write-Host "Fixing expenses table (changing supervisor_id to VARCHAR)..." -ForegroundColor Cyan

$body = @{
    query = $sql
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers $headers -Body $body
    Write-Host "SUCCESS! Table fixed." -ForegroundColor Green
    Write-Host $response
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host "`nDone!" -ForegroundColor Green
