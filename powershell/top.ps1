. .\Lib.ps1

Write-Host -ForegroundColor Green "`n=== CPU ==="

run 'Get-WmiObject Win32_Processor | Select LoadPercentage'

Write-Host -ForegroundColor Green "`n[DEBUG] ps | sort CPU"
Get-Counter '\Process(*)\% Processor Time' `
    | Select-Object -ExpandProperty countersamples `
    | Select-Object -Property instancename, cookedvalue `
    | Sort-Object -Property cookedvalue -Descending | Select-Object -First 20 `
    | ? cookedvalue -gt 1 `
    | ft InstanceName, @{L='CPU';E={($_.Cookedvalue/100).toString('P')}} -AutoSize

    Write-Host -ForegroundColor Green "`n=== Memory ==="

run 'Get-Counter "\Memory\Available MBytes" | Format-Table'

Write-Host -ForegroundColor Green "`n[DEBUG] ps | sort Memory"

# ref: https://stackoverflow.com/a/64080148
Get-Process |
  Group-Object -Property Name -NoElement |
    Where-Object { ! $_.Count -lt 1 } |
      ForEach-Object {
        [PSCustomObject]@{
            Count= $_.Count            
            'Mem(MB)' = [math]::Round(( Get-Process -Name $_.Name |
              Measure-Object WorkingSet -sum).sum /1MB, 0)
            Name = $_.Name
        }
      }  | Sort-Object -Property 'Mem(MB)' -Descending | select -First 10


