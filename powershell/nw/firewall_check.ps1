<#
.SYNOPSIS
    防火墙规则查询脚本
.DESCRIPTION
    列出所有已启用且动作非 Allow 的防火墙规则
.NOTES
    重构自: nw\firewall.ps1
#>

. $PSScriptRoot\..\Lib.ps1

Write-Step '已启用的非 Allow 防火墙规则'
Invoke-Step 'Get-NetFirewallRule -Enabled True | Where-Object { $_.Action -ne "Allow" } | Format-Table -AutoSize'

Invoke-Step 'netsh advfirewall show allprofiles state'