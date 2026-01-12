[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NzY5NTIxMywiZXhwIjoyMDgzMjcxMjEzfQ.MaqKAlb1S9r_yyLZpwszRm0uvYoPP3LVupNl6dI_tlI'
$supabaseUrl = 'https://fwatvgxueajvjcwdokwh.supabase.co'

$headers = @{
    'apikey' = $serviceRoleKey
    'Authorization' = "Bearer $serviceRoleKey"
    'Content-Type' = 'application/json; charset=utf-8'
}

# ========================================
# Step 1: Insert Kitchen user to drivers table
# ========================================
Write-Output "Step 1: Inserting kitchen user to drivers table..."

$kitchenData = @{
    driver_code = "KITCHEN-001"
    full_name = "Kitchen Staff"
    email = "kitchen@antifat.com"
    phone = "0500000002"
    role = "kitchen"
    is_active = $true
} | ConvertTo-Json -Compress

$kitchenBytes = [System.Text.Encoding]::UTF8.GetBytes($kitchenData)

try {
    Invoke-RestMethod -Uri "$supabaseUrl/rest/v1/drivers" -Method POST -Headers $headers -Body $kitchenBytes
    Write-Output "  Kitchen user inserted!"
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 409) {
        Write-Output "  Kitchen user already exists"
    } else {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $responseBody = $reader.ReadToEnd()
        Write-Output "  Error ($statusCode): $responseBody"
    }
}

# ========================================
# Step 2: Create Auth Users
# ========================================
Write-Output "`nStep 2: Creating Auth users..."

$users = @(
    @{ email = "okasha@antifat.com"; password = "antifat2024"; name = "Admin Okasha" },
    @{ email = "kitchen@antifat.com"; password = "antifat2024"; name = "Kitchen Staff" },
    @{ email = "driver@antifat.com"; password = "antifat2024"; name = "Test Driver" }
)

foreach ($user in $users) {
    Write-Output "  Creating auth user: $($user.email)..."

    $authData = @{
        email = $user.email
        password = $user.password
        email_confirm = $true
        user_metadata = @{
            full_name = $user.name
        }
    } | ConvertTo-Json -Compress

    $authBytes = [System.Text.Encoding]::UTF8.GetBytes($authData)

    try {
        $response = Invoke-RestMethod -Uri "$supabaseUrl/auth/v1/admin/users" -Method POST -Headers $headers -Body $authBytes
        Write-Output "    Created: $($response.id)"
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $responseBody = $reader.ReadToEnd()

        if ($responseBody -like "*already been registered*") {
            Write-Output "    Already exists (OK)"
        } else {
            Write-Output "    Error ($statusCode): $responseBody"
        }
    }
}

Write-Output "`n========================================`nSetup complete!`n========================================"