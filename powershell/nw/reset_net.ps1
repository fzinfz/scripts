<#
.SYNOPSIS
    网络协议栈重置脚本
.DESCRIPTION
    依次执行：
    - netsh winsock reset
    - netsh int ip reset
    - netcfg -d（删除所有网络协议和驱动绑定）
    重置后通常需要重启。
.NOTES
    重构自: nw\reset_net.ps1
    需要以管理员身份运行
#>

#Requires -RunAsAdministrator

. $PSScriptRoot\..\Lib.ps1

Write-Warn '此操作将重置网络协议栈，执行后可能需要重启！'
Read-Host -Prompt '按 Enter 继续，Ctrl+C 取消'

Invoke-Steps {
    netsh winsock reset
    netsh int ip reset
    netcfg -d
}

Write-Tip '操作完成，建议重启系统以使更改生效。'
