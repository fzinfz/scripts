<#
.SYNOPSIS
    DNS 查询与缓存检索脚本
.DESCRIPTION
    - 显示当前 DNS 服务器配置
    - 交互式搜索本地 DNS 缓存
.NOTES
    重构自: nw\dns_check.ps1
#>

. $PSScriptRoot\..\Lib.ps1

Write-Step 'DNS 服务器配置'
Invoke-Steps { Get-DnsClientServerAddress | Format-Table -AutoSize }

Write-Step 'DNS 缓存搜索'
$keyword = Read-Host -Prompt 'Get-DnsClientCache | findstr # Input Keyword'
Invoke-Steps { Get-DnsClientCache | findstr $keyword }
