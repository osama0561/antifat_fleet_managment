$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

Write-Host "Creating food_batches table..." -ForegroundColor Cyan

$createTableSQL = @"
CREATE TABLE IF NOT EXISTS food_batches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    batch_code VARCHAR(50) UNIQUE NOT NULL,
    client_name VARCHAR(255) NOT NULL,
    meal_count INTEGER NOT NULL DEFAULT 0,
    delivered_count INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending',
    delivery_location TEXT,
    kitchen_staff_id UUID REFERENCES drivers(id),
    driver_id UUID REFERENCES drivers(id),
    kitchen_signature TEXT,
    driver_signature TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    assigned_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE
);
"@

$body = @{ query = $createTableSQL } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  food_batches table created!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Error: $errorBody" -ForegroundColor Red
}

Write-Host ""
Write-Host "Creating meal_deliveries table..." -ForegroundColor Cyan

$createMealDeliveriesSQL = @"
CREATE TABLE IF NOT EXISTS meal_deliveries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    batch_id UUID REFERENCES food_batches(id),
    meal_number INTEGER NOT NULL,
    recipient_name VARCHAR(255),
    photo_url TEXT,
    delivered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT
);
"@

$body = @{ query = $createMealDeliveriesSQL } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  meal_deliveries table created!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Error: $errorBody" -ForegroundColor Red
}

Write-Host ""
Write-Host "Enabling RLS..." -ForegroundColor Cyan

$rlsSQL = @"
ALTER TABLE food_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_deliveries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for all" ON food_batches;
CREATE POLICY "Enable read for all" ON food_batches FOR SELECT USING (true);

DROP POLICY IF EXISTS "Enable insert for all" ON food_batches;
CREATE POLICY "Enable insert for all" ON food_batches FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update for all" ON food_batches;
CREATE POLICY "Enable update for all" ON food_batches FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Enable read for all" ON meal_deliveries;
CREATE POLICY "Enable read for all" ON meal_deliveries FOR SELECT USING (true);

DROP POLICY IF EXISTS "Enable insert for all" ON meal_deliveries;
CREATE POLICY "Enable insert for all" ON meal_deliveries FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update for all" ON meal_deliveries;
CREATE POLICY "Enable update for all" ON meal_deliveries FOR UPDATE USING (true);
"@

$body = @{ query = $rlsSQL } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  RLS policies created!" -ForegroundColor Green
} catch {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "  Error: $errorBody" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "DONE! Tables created." -ForegroundColor Green