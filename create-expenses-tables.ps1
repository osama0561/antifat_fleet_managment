$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CREATING EXPENSES TABLES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Create supervisors table
Write-Host ""
Write-Host "Creating supervisors table..." -ForegroundColor Magenta

$createSupervisorsSQL = @"
CREATE TABLE IF NOT EXISTS supervisors (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    region VARCHAR(100) NOT NULL,
    initial_balance DECIMAL(10,2) DEFAULT 0,
    current_balance DECIMAL(10,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"@

$body = @{ query = $createSupervisorsSQL } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  supervisors table created!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Error: $errorBody" -ForegroundColor Red
}

# 2. Create expenses table
Write-Host ""
Write-Host "Creating expenses table..." -ForegroundColor Magenta

$createExpensesSQL = @"
CREATE TABLE IF NOT EXISTS expenses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    driver_id UUID REFERENCES drivers(id) NOT NULL,
    supervisor_id UUID REFERENCES supervisors(id),
    amount DECIMAL(10,2) NOT NULL,
    description TEXT NOT NULL,
    expense_type VARCHAR(50) DEFAULT 'general',
    receipt_photo_url TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    approved_by UUID REFERENCES supervisors(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"@

$body = @{ query = $createExpensesSQL } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  expenses table created!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Error: $errorBody" -ForegroundColor Red
}

# 3. Create supervisor_transactions table for balance tracking
Write-Host ""
Write-Host "Creating supervisor_transactions table..." -ForegroundColor Magenta

$createTransactionsSQL = @"
CREATE TABLE IF NOT EXISTS supervisor_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    supervisor_id UUID REFERENCES supervisors(id) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    balance_before DECIMAL(10,2),
    balance_after DECIMAL(10,2),
    expense_id UUID REFERENCES expenses(id),
    notes TEXT,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"@

$body = @{ query = $createTransactionsSQL } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  supervisor_transactions table created!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Error: $errorBody" -ForegroundColor Red
}

# 4. Enable RLS
Write-Host ""
Write-Host "Enabling RLS policies..." -ForegroundColor Magenta

$rlsSQL = @"
ALTER TABLE supervisors ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE supervisor_transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for all" ON supervisors;
CREATE POLICY "Enable read for all" ON supervisors FOR SELECT USING (true);

DROP POLICY IF EXISTS "Enable insert for all" ON supervisors;
CREATE POLICY "Enable insert for all" ON supervisors FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update for all" ON supervisors;
CREATE POLICY "Enable update for all" ON supervisors FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Enable read for all" ON expenses;
CREATE POLICY "Enable read for all" ON expenses FOR SELECT USING (true);

DROP POLICY IF EXISTS "Enable insert for all" ON expenses;
CREATE POLICY "Enable insert for all" ON expenses FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update for all" ON expenses;
CREATE POLICY "Enable update for all" ON expenses FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Enable read for all" ON supervisor_transactions;
CREATE POLICY "Enable read for all" ON supervisor_transactions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Enable insert for all" ON supervisor_transactions;
CREATE POLICY "Enable insert for all" ON supervisor_transactions FOR INSERT WITH CHECK (true);
"@

$body = @{ query = $rlsSQL } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  RLS policies created!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Warning: $errorBody" -ForegroundColor Yellow
}

# 5. Insert supervisors data
Write-Host ""
Write-Host "Inserting supervisors..." -ForegroundColor Magenta

$insertSupervisorsSQL = @"
INSERT INTO supervisors (full_name, phone, region, initial_balance, current_balance)
VALUES
    ('Jassim Hashem', '0555000001', 'Jeddah', 50000, 50000),
    ('Sulaiman Hussein', '0555000002', 'Riyadh', 50000, 50000)
ON CONFLICT DO NOTHING;
"@

$body = @{ query = $insertSupervisorsSQL } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  Supervisors inserted!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Error: $errorBody" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DONE! Tables created successfully" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan