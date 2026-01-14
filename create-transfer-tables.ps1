$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CREATING TRANSFER & BUDGET TABLES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Create budget_periods table for monthly tracking
Write-Host ""
Write-Host "Creating budget_periods table..." -ForegroundColor Magenta

$sql1 = @"
CREATE TABLE IF NOT EXISTS budget_periods (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    period_month INTEGER NOT NULL,
    period_year INTEGER NOT NULL,
    opening_balance DECIMAL(10,2) DEFAULT 0,
    total_distributed DECIMAL(10,2) DEFAULT 0,
    remaining_balance DECIMAL(10,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(period_month, period_year)
);
"@

$body = @{ query = $sql1 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  budget_periods table created!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Error: $errorBody" -ForegroundColor Red
}

# 2. Create supervisor_transfers table
Write-Host ""
Write-Host "Creating supervisor_transfers table..." -ForegroundColor Magenta

$sql2 = @"
CREATE TABLE IF NOT EXISTS supervisor_transfers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    supervisor_id UUID REFERENCES supervisors(id) NOT NULL,
    budget_period_id UUID REFERENCES budget_periods(id),
    amount DECIMAL(10,2) NOT NULL,
    transfer_type VARCHAR(50) DEFAULT 'transfer',
    receipt_url TEXT,
    notes TEXT,
    transfer_date DATE DEFAULT CURRENT_DATE,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"@

$body = @{ query = $sql2 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  supervisor_transfers table created!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Error: $errorBody" -ForegroundColor Red
}

# 3. Add period_id to supervisors for tracking per-period balances
Write-Host ""
Write-Host "Adding columns to supervisors table..." -ForegroundColor Magenta

$sql3 = @"
ALTER TABLE supervisors ADD COLUMN IF NOT EXISTS total_transfers DECIMAL(10,2) DEFAULT 0;
ALTER TABLE supervisors ADD COLUMN IF NOT EXISTS total_expenses DECIMAL(10,2) DEFAULT 0;
"@

$body = @{ query = $sql3 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  Columns added to supervisors!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Warning: $errorBody" -ForegroundColor Yellow
}

# 4. Enable RLS
Write-Host ""
Write-Host "Enabling RLS policies..." -ForegroundColor Magenta

$sql4 = @"
ALTER TABLE budget_periods ENABLE ROW LEVEL SECURITY;
ALTER TABLE supervisor_transfers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable all for budget_periods" ON budget_periods;
CREATE POLICY "Enable all for budget_periods" ON budget_periods FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Enable all for supervisor_transfers" ON supervisor_transfers;
CREATE POLICY "Enable all for supervisor_transfers" ON supervisor_transfers FOR ALL USING (true) WITH CHECK (true);
"@

$body = @{ query = $sql4 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  RLS policies created!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Warning: $errorBody" -ForegroundColor Yellow
}

# 5. Insert current month as initial budget period
Write-Host ""
Write-Host "Creating initial budget period..." -ForegroundColor Magenta

$currentMonth = (Get-Date).Month
$currentYear = (Get-Date).Year

$sql5 = @"
INSERT INTO budget_periods (period_month, period_year, opening_balance, remaining_balance, is_active)
SELECT $currentMonth, $currentYear, COALESCE((SELECT total_budget FROM company_budget LIMIT 1), 0), COALESCE((SELECT remaining_budget FROM company_budget LIMIT 1), 0), true
WHERE NOT EXISTS (SELECT 1 FROM budget_periods WHERE period_month = $currentMonth AND period_year = $currentYear);
"@

$body = @{ query = $sql5 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  Initial budget period created for $currentMonth/$currentYear!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Warning: $errorBody" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DONE! Tables created successfully" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
