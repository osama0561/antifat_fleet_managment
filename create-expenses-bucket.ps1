# Create expenses storage bucket in Supabase

$accessToken = "sbp_a362f03d07161537dd53f7d097ba733d7e33c2fa"
$projectRef = "fwatvgxueajvjcwdokwh"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

# Create the bucket first
$sql1 = @"
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('reports', 'reports', true, 10485760, ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO UPDATE SET public = true;
"@

Write-Host "Creating reports storage bucket..." -ForegroundColor Cyan

$body = @{
    query = $sql1
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers $headers -Body $body
    Write-Host "Bucket created/updated successfully!" -ForegroundColor Green
} catch {
    Write-Host "Bucket error: $_" -ForegroundColor Yellow
}

# Drop existing policies and create new ones
$sql2 = @"
DROP POLICY IF EXISTS "Allow authenticated uploads to reports" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to reports" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates to reports" ON storage.objects;
DROP POLICY IF EXISTS "Allow anon uploads to reports" ON storage.objects;
DROP POLICY IF EXISTS "Allow anon read reports" ON storage.objects;

CREATE POLICY "Allow anon uploads to reports" ON storage.objects
FOR INSERT TO anon
WITH CHECK (bucket_id = 'reports');

CREATE POLICY "Allow authenticated uploads to reports" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'reports');

CREATE POLICY "Allow anon read reports" ON storage.objects
FOR SELECT TO anon
USING (bucket_id = 'reports');

CREATE POLICY "Allow public read access to reports" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'reports');
"@

Write-Host "Setting up storage policies..." -ForegroundColor Cyan

$body2 = @{
    query = $sql2
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers $headers -Body $body2
    Write-Host "Policies configured successfully!" -ForegroundColor Green
} catch {
    Write-Host "Policy error (may be OK if already exists): $_" -ForegroundColor Yellow
}

Write-Host "`nDone! The reports bucket should now be ready." -ForegroundColor Green
