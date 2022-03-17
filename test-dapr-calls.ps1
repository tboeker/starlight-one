Write-Host "App1 health"
Invoke-RestMethod -Method Get -Uri "http://localhost:3500/v1.0/invoke/app1/method/health"
Write-Host "App2 health (through App1)"
Invoke-RestMethod -Method Get -Uri "http://localhost:3500/v1.0/invoke/app1/method/healthapp2"