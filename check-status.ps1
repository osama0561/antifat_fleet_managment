$headers = @{
    'apikey' = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2OTUyMTMsImV4cCI6MjA4MzI3MTIxM30.agTQDa2tEM7nvV6fzW_9K-RTK-o3vwxMatgUvuROXdA'
    'Authorization' = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2OTUyMTMsImV4cCI6MjA4MzI3MTIxM30.agTQDa2tEM7nvV6fzW_9K-RTK-o3vwxMatgUvuROXdA'
}
$result = Invoke-RestMethod -Uri 'https://fwatvgxueajvjcwdokwh.supabase.co/rest/v1/vehicles?select=status&limit=5' -Method GET -Headers $headers
$result | ForEach-Object { $_.status }
