. $PSScriptRoot\..\Lib.ps1

# ─── 接口与地址 ───────────────────────────────
Write-Step '网络接口（IPv4，排除 Loopback）'
Write-Tip 'Get-NetIPInterface -AddressFamily IPv4 | ? { $_.InterfaceAlias -notmatch "Loopback.*" } | sort -Property ifIndex | ft'
Get-NetIPInterface -AddressFamily IPv4 |
    Where-Object { $_.InterfaceAlias -notmatch 'Loopback.*' } |
    Sort-Object ifIndex |
    Format-Table -AutoSize

Write-Step 'IPv4 地址列表'
Invoke-Steps { Get-NetIPAddress -AddressFamily IPv4 | Sort-Object ifIndex | Format-Table -AutoSize }

Write-Step '网卡列表'
Invoke-Steps { Get-NetAdapter | Sort-Object Name | Format-Table -AutoSize }

Write-Step '网卡电源管理'
Invoke-Steps { Get-NetAdapterPowerManagement -Name '*' | Select-Object DeviceSleepOnDisconnect, WakeOnMagicPacket, Name | Sort-Object Name | Format-Table -AutoSize }