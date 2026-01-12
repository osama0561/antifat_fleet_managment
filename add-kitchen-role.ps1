[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NzY5NTIxMywiZXhwIjoyMDgzMjcxMjEzfQ.MaqKAlb1S9r_yyLZpwszRm0uvYoPP3LVupNl6dI_tlI'
$supabaseUrl = 'https://fwatvgxueajvjcwdokwh.supabase.co'

$headers = @{
    'apikey' = $serviceRoleKey
    'Authorization' = "Bearer $serviceRoleKey"
    'Content-Type' = 'application/json'
}

# Use RPC to execute SQL
$sql = @'
DO $$
BEGIN
    -- Drop existing constraint
    ALTER TABLE drivers DROP CONSTRAINT IF EXISTS drivers_role_check;

    -- Add new constraint with kitchen role
    ALTER TABLE drivers ADD CONSTRAINT drivers_role_check
    CHECK (role IN ('admin', 'driver', 'kitchen'));
END $$;
'@

$body = @{
    query = $sql
} | ConvertTo-Json

Write-Output "Modifying drivers_role_check constraint to include 'kitchen'..."

try {
    # Try using the rpc endpoint for raw SQL
    $response = Invoke-RestMethod -Uri "$supabaseUrl/rest/v1/rpc/exec_sql" -Method POST -Headers $headers -Body $body
    Write-Output "Constraint modified successfully!"
    Write-Output $response
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $responseBody = $reader.ReadToEnd()
    Write-Output "RPC method not available ($statusCode): $responseBody"
    Write-Output "`nYou need to run this SQL in the Supabase SQL Editor:"
    Write-Output "----------------------------------------"
    Write-Output "ALTER TABLE drivers DROP CONSTRAINT IF EXISTS drivers_role_check;"
    Write-Output "ALTER TABLE drivers ADD CONSTRAINT drivers_role_check CHECK (role IN ('admin', 'driver', 'kitchen'));"
    Write-Output "----------------------------------------"
}