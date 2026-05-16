<#
.SYNOPSIS
    TCP 监听端口查询脚本
.DESCRIPTION
    列出处于 Listen 状态的 TCP 连接及所属进程名，
    并显示动态端口范围提示。
.NOTES
    重构自: nw\ports.ps1
#>

. $PSScriptRoot\..\Lib.ps1

Write-Step 'TCP 监听端口 (Listen)'
Get-NetTCPConnection -State Listen |
    Sort-Object LocalPort |
    Select-Object -Property State, LocalAddress, LocalPort,
        @{
            Name       = 'ProcessName'
            Expression = { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name }
        } |
    Format-Table -AutoSize

Write-Step '动态端口范围'
Invoke-Steps { netsh int ipv4 show dynamicportrange tcp }

Write-Tip 'netsh int ipv4 set dynamicport tcp start=40000 num=25536'
