<#
.SYNOPSIS
    DNS query and cache lookup script
.DESCRIPTION
    - Display current DNS server configuration
    - Interactive search of local DNS cache
.NOTES
    Refactored from: nw\dns_check.ps1
#>

. $PSScriptRoot\..\Lib.ps1

Write-Step 'DNS Server Configuration'
Invoke-Steps { Get-DnsClientServerAddress | Format-Table -AutoSize }

Write-Step 'DNS Cache Search'
$keyword = Read-Host -Prompt 'Get-DnsClientCache | findstr # Input Keyword'
Invoke-Steps { Get-DnsClientCache | findstr $keyword }