$headers = @{
    'apikey' = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2OTUyMTMsImV4cCI6MjA4MzI3MTIxM30.agTQDa2tEM7nvV6fzW_9K-RTK-o3vwxMatgUvuROXdA'
}

$response = Invoke-RestMethod -Uri 'https://fwatvgxueajvjcwdokwh.supabase.co/rest/v1/drivers?select=role' -Headers $headers
$uniqueRoles = $response | Select-Object -Property role -Unique
Write-Output "Unique roles in drivers table:"
$uniqueRoles | Format-Table
