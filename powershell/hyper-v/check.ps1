. ..\Lib.ps1

run '
Get-VM
Get-VMSwitch | ft
'

get-vm | ? State -ne "Running" | % {
    Write-Host -ForegroundColor Green `n[TIP] Start-VM $_.Name
}