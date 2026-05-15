<#
.SYNOPSIS
    列出 Hyper-V 及 PnP 相关 PowerShell 命令
.DESCRIPTION
    - 列出 PnpDevice 模块命令
    - 搜索 VMAssignableDevice 相关命令
    - 搜索 VmHostAssignableDevice 相关命令
    - 列出 Hyper-V 模块所有命令
.NOTES
    重构自: hyper-v\get_cmds.ps1
#>

. $PSScriptRoot\..\Lib.ps1

Write-Step 'PnpDevice 模块命令'
Get-Command -Module PnpDevice | Format-Table -AutoSize

Write-Tip 'VMAssignableDevice 命令:'
(Get-Command).Where{ $_.Name -like '*VMAssignableDevice*' } | Format-Table -AutoSize

Write-Tip 'VmHostAssignableDevice 命令:'
(Get-Command).Where{ $_.Name -like '*VmHostAssignableDevice*' } | Format-Table -AutoSize

Write-Step 'Hyper-V 模块命令'
Invoke-Step 'Get-Command -Module Hyper-V | Format-Table -AutoSize'
