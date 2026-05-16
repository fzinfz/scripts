<#
.SYNOPSIS
    List Hyper-V and PnP Related PowerShell Commands
.DESCRIPTION
    - Lists PnpDevice module commands
    - Searches VMAssignableDevice related commands
    - Searches VmHostAssignableDevice related commands
    - Lists all Hyper-V module commands
.NOTES
    Refactored from: hyper-v\get_cmds.ps1
#>

. $PSScriptRoot\..\Lib.ps1

Write-Step 'PnpDevice Module Commands'
Get-Command -Module PnpDevice | Format-Table -AutoSize

Write-Tip 'VMAssignableDevice Commands:'
(Get-Command).Where{ $_.Name -like '*VMAssignableDevice*' } | Format-Table -AutoSize

Write-Tip 'VmHostAssignableDevice Commands:'
(Get-Command).Where{ $_.Name -like '*VmHostAssignableDevice*' } | Format-Table -AutoSize

Write-Step 'Hyper-V Module Commands'
Invoke-Steps { Get-Command -Module Hyper-V | Format-Table -AutoSize }
