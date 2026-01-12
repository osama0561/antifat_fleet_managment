[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$headers = @{
    'apikey' = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2OTUyMTMsImV4cCI6MjA4MzI3MTIxM30.agTQDa2tEM7nvV6fzW_9K-RTK-o3vwxMatgUvuROXdA'
    'Authorization' = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2OTUyMTMsImV4cCI6MjA4MzI3MTIxM30.agTQDa2tEM7nvV6fzW_9K-RTK-o3vwxMatgUvuROXdA'
    'Content-Type' = 'application/json; charset=utf-8'
}

# Insert kitchen user
$kitchenData = @{
    driver_code = "KITCHEN-001"
    full_name = "Kitchen Staff"
    email = "kitchen@antifat.com"
    phone = "0500000002"
    role = "kitchen"
    is_active = $true
}

$kitchenBody = $kitchenData | ConvertTo-Json -Compress
$kitchenBytes = [System.Text.Encoding]::UTF8.GetBytes($kitchenBody)

Write-Output "Inserting kitchen user..."
Write-Output "Body: $kitchenBody"
try {
    $response = Invoke-RestMethod -Uri 'https://fwatvgxueajvjcwdokwh.supabase.co/rest/v1/drivers' -Method POST -Headers $headers -Body $kitchenBytes
    Write-Output "Kitchen user inserted successfully!"
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Output "Error ($statusCode): $($_.Exception.Message)"
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $responseBody = $reader.ReadToEnd()
    Write-Output "Response: $responseBody"
}

# Insert driver test user
$driverData = @{
    driver_code = "DRV-TEST"
    full_name = "Test Driver"
    email = "driver@antifat.com"
    phone = "0500000003"
    role = "driver"
    is_active = $true
    driver_type = "permanent"
}

$driverBody = $driverData | ConvertTo-Json -Compress
$driverBytes = [System.Text.Encoding]::UTF8.GetBytes($driverBody)

Write-Output "`nInserting driver user..."
Write-Output "Body: $driverBody"
try {
    $response = Invoke-RestMethod -Uri 'https://fwatvgxueajvjcwdokwh.supabase.co/rest/v1/drivers' -Method POST -Headers $headers -Body $driverBytes
    Write-Output "Driver user inserted successfully!"
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Output "Error ($statusCode): $($_.Exception.Message)"
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $responseBody = $reader.ReadToEnd()
    Write-Output "Response: $responseBody"
}
