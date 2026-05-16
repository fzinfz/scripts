. $PSScriptRoot\..\Lib.ps1

# --- Interfaces and Addresses -----------------------------------------------
Write-Step 'Network Interfaces (IPv4, excluding Loopback)'
Write-Tip 'Get-NetIPInterface -AddressFamily IPv4 | ? { $_.InterfaceAlias -notmatch "Loopback.*" } | sort -Property ifIndex | ft'
Get-NetIPInterface -AddressFamily IPv4 |
    Where-Object { $_.InterfaceAlias -notmatch 'Loopback.*' } |
    Sort-Object ifIndex |
    Format-Table -AutoSize

Write-Step 'IPv4 Address List'
Invoke-Steps { Get-NetIPAddress -AddressFamily IPv4 | Sort-Object ifIndex | Format-Table -AutoSize }

Write-Step 'Network Adapter List'
Invoke-Steps { Get-NetAdapter | Sort-Object Name | Format-Table -AutoSize }

Write-Step 'Network Adapter Power Management'
Invoke-Steps { Get-NetAdapterPowerManagement -Name '*' | Select-Object DeviceSleepOnDisconnect, WakeOnMagicPacket, Name | Sort-Object Name | Format-Table -AutoSize }