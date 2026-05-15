<#
.SYNOPSIS
    交互式 TraceRoute 工具
.DESCRIPTION
    提示用户输入目标主机，然后执行 Test-NetConnection -TraceRoute
.NOTES
    重构自: nw\trace_route.ps1
#>

$dest = Read-Host -Prompt 'Test-NetConnection -TraceRoute <目标主机或 IP>'
Test-NetConnection -TraceRoute $dest
