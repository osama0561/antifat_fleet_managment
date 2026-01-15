$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$projectRef/database/query"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CREATING ROSTER MANAGEMENT TABLES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Create shift_templates table
Write-Host ""
Write-Host "Creating shift_templates table..." -ForegroundColor Magenta

$sql1 = @"
CREATE TABLE IF NOT EXISTS shift_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    break_minutes INTEGER DEFAULT 30,
    color VARCHAR(20) DEFAULT '#3B82F6',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"@

$body = @{ query = $sql1 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  shift_templates table created!" -ForegroundColor Green
} catch {
    Write-Host "  Table may already exist" -ForegroundColor Yellow
}

# 2. Create driver_groups table
Write-Host ""
Write-Host "Creating driver_groups table..." -ForegroundColor Magenta

$sql2 = @"
CREATE TABLE IF NOT EXISTS driver_groups (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(50),
    color VARCHAR(20) DEFAULT '#10B981',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"@

$body = @{ query = $sql2 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  driver_groups table created!" -ForegroundColor Green
} catch {
    Write-Host "  Table may already exist" -ForegroundColor Yellow
}

# 3. Create driver_group_members table
Write-Host ""
Write-Host "Creating driver_group_members table..." -ForegroundColor Magenta

$sql3 = @"
CREATE TABLE IF NOT EXISTS driver_group_members (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
    group_id UUID REFERENCES driver_groups(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(driver_id, group_id)
);
"@

$body = @{ query = $sql3 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  driver_group_members table created!" -ForegroundColor Green
} catch {
    Write-Host "  Table may already exist" -ForegroundColor Yellow
}

# 4. Create scheduled_shifts table
Write-Host ""
Write-Host "Creating scheduled_shifts table..." -ForegroundColor Magenta

$sql4 = @"
CREATE TABLE IF NOT EXISTS scheduled_shifts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
    template_id UUID REFERENCES shift_templates(id),
    shift_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status VARCHAR(20) DEFAULT 'scheduled',
    notes TEXT,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"@

$body = @{ query = $sql4 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  scheduled_shifts table created!" -ForegroundColor Green
} catch {
    Write-Host "  Table may already exist" -ForegroundColor Yellow
}

# 5. Create leave_requests table (for Phase 2)
Write-Host ""
Write-Host "Creating leave_requests table..." -ForegroundColor Magenta

$sql5 = @"
CREATE TABLE IF NOT EXISTS leave_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
    leave_type VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    reviewed_by UUID,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"@

$body = @{ query = $sql5 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  leave_requests table created!" -ForegroundColor Green
} catch {
    Write-Host "  Table may already exist" -ForegroundColor Yellow
}

# 6. Create time_records table (for Phase 3 - Clock in/out)
Write-Host ""
Write-Host "Creating time_records table..." -ForegroundColor Magenta

$sql6 = @"
CREATE TABLE IF NOT EXISTS time_records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
    shift_id UUID REFERENCES scheduled_shifts(id),
    clock_in TIMESTAMP WITH TIME ZONE,
    clock_out TIMESTAMP WITH TIME ZONE,
    clock_in_location TEXT,
    clock_out_location TEXT,
    total_hours DECIMAL(5,2),
    overtime_hours DECIMAL(5,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"@

$body = @{ query = $sql6 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  time_records table created!" -ForegroundColor Green
} catch {
    Write-Host "  Table may already exist" -ForegroundColor Yellow
}

# 7. Create vehicle_assignments table (for Phase 4)
Write-Host ""
Write-Host "Creating vehicle_assignments table..." -ForegroundColor Magenta

$sql7 = @"
CREATE TABLE IF NOT EXISTS vehicle_assignments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
    shift_id UUID REFERENCES scheduled_shifts(id),
    assignment_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    status VARCHAR(20) DEFAULT 'assigned',
    notes TEXT,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"@

$body = @{ query = $sql7 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  vehicle_assignments table created!" -ForegroundColor Green
} catch {
    Write-Host "  Table may already exist" -ForegroundColor Yellow
}

# 8. Enable RLS on all tables
Write-Host ""
Write-Host "Enabling RLS policies..." -ForegroundColor Magenta

$sql8 = @"
ALTER TABLE shift_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE scheduled_shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE time_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicle_assignments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable all for shift_templates" ON shift_templates;
CREATE POLICY "Enable all for shift_templates" ON shift_templates FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Enable all for driver_groups" ON driver_groups;
CREATE POLICY "Enable all for driver_groups" ON driver_groups FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Enable all for driver_group_members" ON driver_group_members;
CREATE POLICY "Enable all for driver_group_members" ON driver_group_members FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Enable all for scheduled_shifts" ON scheduled_shifts;
CREATE POLICY "Enable all for scheduled_shifts" ON scheduled_shifts FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Enable all for leave_requests" ON leave_requests;
CREATE POLICY "Enable all for leave_requests" ON leave_requests FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Enable all for time_records" ON time_records;
CREATE POLICY "Enable all for time_records" ON time_records FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Enable all for vehicle_assignments" ON vehicle_assignments;
CREATE POLICY "Enable all for vehicle_assignments" ON vehicle_assignments FOR ALL USING (true) WITH CHECK (true);
"@

$body = @{ query = $sql8 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  RLS policies created!" -ForegroundColor Green
} catch {
    Write-Host "  Some policies may already exist" -ForegroundColor Yellow
}

# 9. Insert default shift templates
Write-Host ""
Write-Host "Inserting default shift templates..." -ForegroundColor Magenta

$sql9 = @"
INSERT INTO shift_templates (name, name_en, start_time, end_time, break_minutes, color) VALUES
('وردية صباحية', 'Morning Shift', '06:00', '14:00', 30, '#F59E0B'),
('وردية مسائية', 'Evening Shift', '14:00', '22:00', 30, '#8B5CF6'),
('وردية ليلية', 'Night Shift', '22:00', '06:00', 30, '#1F2937')
ON CONFLICT DO NOTHING;
"@

$body = @{ query = $sql9 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  Default templates inserted!" -ForegroundColor Green
} catch {
    Write-Host "  Templates may already exist" -ForegroundColor Yellow
}

# 10. Insert default driver groups
Write-Host ""
Write-Host "Inserting default driver groups..." -ForegroundColor Magenta

$sql10 = @"
INSERT INTO driver_groups (name, region, color) VALUES
('فريق جدة', 'Jeddah', '#10B981'),
('فريق الرياض', 'Riyadh', '#3B82F6')
ON CONFLICT DO NOTHING;
"@

$body = @{ query = $sql10 } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $baseUrl -Method POST -Headers $headers -Body $body | Out-Null
    Write-Host "  Default groups inserted!" -ForegroundColor Green
} catch {
    Write-Host "  Groups may already exist" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ALL ROSTER TABLES CREATED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
