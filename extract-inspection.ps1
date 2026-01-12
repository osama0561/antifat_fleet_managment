$jsonlPath = "C:\Users\him\.claude\projects\e--Youtube-Agentic-Workflow-execution-20251206T152422Z-1-001\130654e1-7e0c-4a4b-8fbc-216405582c4c.jsonl"

# Read line 14 (index 13) which contains the inspection.html tool result
$lines = Get-Content $jsonlPath
$line14 = $lines[13]

# Parse as JSON
$json = $line14 | ConvertFrom-Json

# Show structure
Write-Host "Message type: $($json.type)" -ForegroundColor Cyan
Write-Host "Content items: $($json.message.content.Count)" -ForegroundColor Cyan

foreach ($item in $json.message.content) {
    Write-Host "  - Type: $($item.type)" -ForegroundColor Yellow
    if ($item.tool_use_id) {
        Write-Host "    Tool ID: $($item.tool_use_id)" -ForegroundColor Gray
    }
    if ($item.content) {
        Write-Host "    Content items: $($item.content.Count)" -ForegroundColor Gray
        foreach ($c in $item.content) {
            Write-Host "      - Type: $($c.type), Length: $($c.text.Length)" -ForegroundColor Gray
        }
    }
}