# Create/update expenses table in Supabase

$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$sql = @"
-- Create expenses table if it doesn't exist
CREATE TABLE IF NOT EXISTS expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID REFERENCES drivers(id),
    supervisor_id VARCHAR(100),
    supervisor_name VARCHAR(255),
    company_paid BOOLEAN DEFAULT false,
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    expense_type VARCHAR(50) NOT NULL,
    receipt_photo_url TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add columns if they don't exist (for existing tables)
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS supervisor_id VARCHAR(100);
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS supervisor_name VARCHAR(255);
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS company_paid BOOLEAN DEFAULT false;
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS expense_type VARCHAR(50);
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS receipt_photo_url TEXT;
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- Enable RLS
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Drivers can insert own expenses" ON expenses;
DROP POLICY IF EXISTS "Drivers can view own expenses" ON expenses;
DROP POLICY IF EXISTS "Allow all inserts on expenses" ON expenses;
DROP POLICY IF EXISTS "Allow all selects on expenses" ON expenses;

-- Create policies for anon access (since drivers use anon key)
CREATE POLICY "Allow all inserts on expenses" ON expenses FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Allow all selects on expenses" ON expenses FOR SELECT TO anon USING (true);
CREATE POLICY "Drivers can insert own expenses" ON expenses FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Drivers can view own expenses" ON expenses FOR SELECT TO authenticated USING (true);
"@

Write-Host "Creating/updating expenses table..." -ForegroundColor Cyan

$body = @{
    query = $sql
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers $headers -Body $body
    Write-Host "SUCCESS! Expenses table configured." -ForegroundColor Green
    Write-Host $response
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host "`nDone!" -ForegroundColor Green
