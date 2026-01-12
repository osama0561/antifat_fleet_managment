$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

$tables = @('drivers', 'vehicles', 'inspections', 'maintenance_reports', 'accident_reports', 'food_deliveries', 'attendance')

foreach ($table in $tables) {
    Write-Host ""
    Write-Host "=== $table ===" -ForegroundColor Cyan

    $sql = "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = '$table' ORDER BY ordinal_position;"
    $body = @{ query = $sql } | ConvertTo-Json

    try {
        $result = Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body
        $result | ForEach-Object {
            Write-Host "  $($_.column_name) ($($_.data_type)) $(if($_.is_nullable -eq 'YES'){'nullable'}else{'required'})" -ForegroundColor White
        }
    } catch {
        Write-Host "  Error getting schema" -ForegroundColor Red
    }
}