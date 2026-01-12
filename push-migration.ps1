[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NzY5NTIxMywiZXhwIjoyMDgzMjcxMjEzfQ.MaqKAlb1S9r_yyLZpwszRm0uvYoPP3LVupNl6dI_tlI'
$supabaseUrl = 'https://fwatvgxueajvjcwdokwh.supabase.co'

$headers = @{
    'apikey' = $serviceRoleKey
    'Authorization' = "Bearer $serviceRoleKey"
    'Content-Type' = 'application/json'
}

Write-Output "========================================="
Write-Output "FleetCheck - Food Delivery v2 Migration"
Write-Output "========================================="

# SQL statements to execute (split into individual statements)
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

    # 2. Create index for daily_reports
    "CREATE INDEX IF NOT EXISTS idx_daily_reports_driver_date ON daily_reports(driver_id, report_date)",

    # 3. Create meal_transfers table
    @"
CREATE TABLE IF NOT EXISTS meal_transfers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    from_driver_id UUID NOT NULL REFERENCES drivers(id),
    to_driver_id UUID NOT NULL REFERENCES drivers(id),
    transfer_date DATE NOT NULL,
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

    # 4. Create indexes for meal_transfers
    "CREATE INDEX IF NOT EXISTS idx_meal_transfers_from ON meal_transfers(from_driver_id, transfer_date)",
    "CREATE INDEX IF NOT EXISTS idx_meal_transfers_to ON meal_transfers(to_driver_id, transfer_date, status)",

    # 5. Enable RLS
    "ALTER TABLE daily_reports ENABLE ROW LEVEL SECURITY",
    "ALTER TABLE meal_transfers ENABLE ROW LEVEL SECURITY",

    # 6. Create policies (drop first if exists to avoid errors)
    "DROP POLICY IF EXISTS daily_reports_all ON daily_reports",
    "CREATE POLICY daily_reports_all ON daily_reports FOR ALL USING (true) WITH CHECK (true)",
    "DROP POLICY IF EXISTS meal_transfers_all ON meal_transfers",
    "CREATE POLICY meal_transfers_all ON meal_transfers FOR ALL USING (true) WITH CHECK (true)",

    # 7. Grant permissions
    "GRANT ALL ON daily_reports TO anon, authenticated",
    "GRANT ALL ON meal_transfers TO anon, authenticated"
)

# Try using the pg endpoint
Write-Output "`nAttempting to execute SQL via pg endpoint..."

$successCount = 0
$failCount = 0

foreach ($sql in $sqlStatements) {
    $shortSql = if ($sql.Length -gt 60) { $sql.Substring(0, 60) + "..." } else { $sql }
    Write-Output "`n>> Executing: $shortSql"

    $body = @{
        query = $sql
    } | ConvertTo-Json

    try {
        # Try pg endpoint
        $response = Invoke-RestMethod -Uri "$supabaseUrl/pg/query" -Method POST -Headers $headers -Body $body -ErrorAction Stop
        Write-Output "   SUCCESS"
        $successCount++
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__

        if ($statusCode -eq 404) {
            # pg endpoint not available, try alternative
            Write-Output "   pg endpoint not available (404)"
            $failCount++
        } else {
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $responseBody = $reader.ReadToEnd()

                # Check if it's just "already exists" type error
                if ($responseBody -like "*already exists*" -or $responseBody -like "*duplicate*") {
                    Write-Output "   OK (already exists)"
                    $successCount++
                } else {
                    Write-Output "   FAILED ($statusCode): $responseBody"
                    $failCount++
                }
            } catch {
                Write-Output "   FAILED: $($_.Exception.Message)"
                $failCount++
            }
        }
    }
}

Write-Output "`n========================================="
Write-Output "Migration Summary:"
Write-Output "  Success: $successCount"
Write-Output "  Failed: $failCount"
Write-Output "========================================="

if ($failCount -gt 0) {
    Write-Output "`nNOTE: If pg endpoint failed, you need to run the SQL manually."
    Write-Output "Go to: https://supabase.com/dashboard/project/fwatvgxueajvjcwdokwh/sql"
    Write-Output "And paste the contents of: migrate-food-delivery-v2.sql"
}