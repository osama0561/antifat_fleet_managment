$token = 'sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa'
$projectRef = 'fwatvgxueajvjcwdokwh'

Write-Host "========================================="
Write-Host "FleetCheck - Running SQL Migration"
Write-Host "========================================="

$headers = @{
    'Authorization' = "Bearer $token"
    'Content-Type' = 'application/json'
}

# SQL statements to run
$sqlStatements = @(
    # 1. Create daily_reports table
    @"
CREATE TABLE IF NOT EXISTS daily_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    driver_id UUID NOT NULL REFERENCES drivers(id),
    report_date DATE NOT NULL,
    brand_mawzon INTEGER DEFAULT 0,
    brand_antifat INTEGER DEFAULT 0,
    brand_ck INTEGER DEFAULT 0,
    brand_routine INTEGER DEFAULT 0,
    brand_myhealthy INTEGER DEFAULT 0,
    total_meals INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(driver_id, report_date)
)
"@,

    # 2. Create meal_transfers table
    @"
CREATE TABLE IF NOT EXISTS meal_transfers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    from_driver_id UUID NOT NULL REFERENCES drivers(id),
    to_driver_id UUID NOT NULL REFERENCES drivers(id),
    transfer_date DATE NOT NULL,
    client_name VARCHAR(255),
    subscription_id VARCHAR(50),
    district VARCHAR(100),
    duration VARCHAR(20) DEFAULT 'permanent',
    brand_mawzon INTEGER DEFAULT 0,
    brand_antifat INTEGER DEFAULT 0,
    brand_ck INTEGER DEFAULT 0,
    brand_routine INTEGER DEFAULT 0,
    brand_myhealthy INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    accepted_at TIMESTAMPTZ,
    CONSTRAINT no_self_transfer CHECK (from_driver_id != to_driver_id)
)
"@,

    # 3. Enable RLS
    "ALTER TABLE daily_reports ENABLE ROW LEVEL SECURITY",
    "ALTER TABLE meal_transfers ENABLE ROW LEVEL SECURITY",

    # 4. Policies
    "DROP POLICY IF EXISTS daily_reports_all ON daily_reports",
    "CREATE POLICY daily_reports_all ON daily_reports FOR ALL USING (true) WITH CHECK (true)",
    "DROP POLICY IF EXISTS meal_transfers_all ON meal_transfers",
    "CREATE POLICY meal_transfers_all ON meal_transfers FOR ALL USING (true) WITH CHECK (true)",

    # 5. Grants
    "GRANT ALL ON daily_reports TO anon, authenticated",
    "GRANT ALL ON meal_transfers TO anon, authenticated"
)

$success = 0
$failed = 0

foreach ($sql in $sqlStatements) {
    $shortSql = if ($sql.Length -gt 50) { $sql.Substring(0, 50) + "..." } else { $sql }
    Write-Host "`n>> $shortSql"

    $body = @{ query = $sql } | ConvertTo-Json -Compress

    try {
        $response = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers $headers -Body $body -ErrorAction Stop
        Write-Host "   OK" -ForegroundColor Green
        $success++
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   FAILED ($statusCode)" -ForegroundColor Red

        # Check if already exists
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            if ($errorBody -like "*already exists*") {
                Write-Host "   (already exists - OK)" -ForegroundColor Yellow
                $success++
            } else {
                Write-Host "   $errorBody"
                $failed++
            }
        } catch {
            $failed++
        }
    }
}

Write-Host "`n========================================="
Write-Host "Done! Success: $success, Failed: $failed"
Write-Host "========================================="