<#
.SYNOPSIS
    Host basic info query
.DESCRIPTION
    Output hostname and IPv4 DHCP address list
.NOTES
    Refactored from: host_info.ps1
#>

. $PSScriptRoot\..\Lib.ps1

Write-Step 'Host Basic Info'
Invoke-Steps {
hostname
Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp | Select-Object InterfaceAlias, IPAddress, ValidLifetime | Format-Table -AutoSize
}