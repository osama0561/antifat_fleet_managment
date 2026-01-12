$webhookUrl = "https://n8n.srv1200431.hstgr.cloud/webhook/inspection-issues"

Write-Host "Testing Inspection Issues Webhook..." -ForegroundColor Cyan
Write-Host "URL: $webhookUrl" -ForegroundColor Gray
Write-Host ""

# Test payload with inspection issues
$testData = @{
    inspection_code = "INS-TEST-WEBHOOK-001"
    inspection_type = "receive"
    driver_name = "Ahmed Al-Fahad"
    driver_code = "DRV-TEST-001"
    driver_email = "driver@antifat.com"
    vehicle_code = "VAN-TEST-001"
    plate_number = "ABC 1234"
    issues = @(
        "Back light not working"
        "Right signal not working"
        "Fridge not working"
    )
    odometer_reading = 87650
    submitted_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}

$body = $testData | ConvertTo-Json -Depth 3

Write-Host "Payload:" -ForegroundColor Yellow
Write-Host $body
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri $webhookUrl -Method POST -Headers @{ "Content-Type" = "application/json" } -Body $body
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "Response Body: $errorBody" -ForegroundColor Red
    }
}
