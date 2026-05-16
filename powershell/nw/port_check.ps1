<#
.SYNOPSIS
    TCP listening port query script
.DESCRIPTION
    List TCP connections in Listen state and their process names,
    and show dynamic port range hint.
.NOTES
    Refactored from: nw\ports.ps1
#>

. $PSScriptRoot\..\Lib.ps1

Write-Step 'TCP Listening Ports (Listen)'
Get-NetTCPConnection -State Listen |
    Sort-Object LocalPort |
    Select-Object -Property State, LocalAddress, LocalPort,
        @{
            Name       = 'ProcessName'
            Expression = { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name }
        } |
    Format-Table -AutoSize

Write-Step 'Dynamic Port Range'
Invoke-Steps { netsh int ipv4 show dynamicportrange tcp }

Write-Tip 'netsh int ipv4 set dynamicport tcp start=40000 num=25536'