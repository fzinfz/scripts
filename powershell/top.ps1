. .\Init.lib.ps1

Write-Host -ForegroundColor Green "`n=== CPU ==="

run 'Get-WmiObject Win32_Processor | Select LoadPercentage'

Write-Host -ForegroundColor Green "`n[DEBUG] ps | sort CPU"
Get-Counter '\Process(*)\% Processor Time' `
    | Select-Object -ExpandProperty countersamples `
    | Select-Object -Property instancename, cookedvalue `
    | Sort-Object -Property cookedvalue -Descending | Select-Object -First 20 `
    | ? { $_.cookedvalue -gt 1 } `
    | ft InstanceName, @{L='CPU';E={($_.Cookedvalue/100).toString('P')}} -AutoSize

    Write-Host -ForegroundColor Green "`n=== Memory ==="

run 'Get-Counter "\Memory\Available MBytes" | Format-Table'

Write-Host -ForegroundColor Green "`n[DEBUG] ps | sort Working Set"
ps | sort WS -Descending | select -First 10 |
    Format-Table `
    @{Label = "NonPagedMem(K)"; Expression = {[int]($_.NPM / 1KB)}},
    @{Label = "PM(M)"; Expression = {[int]($_.PM / 1MB)}},    
    @{Label = "CPU(s)"; Expression = {if ($_.CPU) {$_.CPU.ToString("N")}}},
    @{Label = "WS(M)"; Expression = {[int]($_.WS / 1MB)}},
    Id, ProcessName -AutoSize



