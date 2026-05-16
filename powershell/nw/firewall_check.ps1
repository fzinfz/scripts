<#
.SYNOPSIS
    Firewall rule query script
.DESCRIPTION
    List all enabled firewall rules with action not Allow
.NOTES
    Refactored from: nw\firewall.ps1
#>

. $PSScriptRoot\..\Lib.ps1

Write-Step 'Enabled Non-Allow Firewall Rules'
Invoke-Steps { Get-NetFirewallRule -Enabled True | Where-Object { $_.Action -ne 'Allow' } | Format-Table -AutoSize }

Invoke-Steps { netsh advfirewall show allprofiles state }