<#
.SYNOPSIS
    主机基本信息查询
.DESCRIPTION
    输出主机名及 IPv4 DHCP 地址列表
.NOTES
    重构自: host_info.ps1
#>

. $PSScriptRoot\..\Lib.ps1

Write-Step '主机基本信息'
Invoke-Steps {
hostname
Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp | Select-Object InterfaceAlias, IPAddress, ValidLifetime | Format-Table -AutoSize
}
