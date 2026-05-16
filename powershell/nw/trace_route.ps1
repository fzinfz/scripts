<#
.SYNOPSIS
    Interactive TraceRoute tool
.DESCRIPTION
    Prompt user to enter target host, then execute Test-NetConnection -TraceRoute
.NOTES
    Refactored from: nw\trace_route.ps1
#>

$dest = Read-Host -Prompt 'Test-NetConnection -TraceRoute <Target Host or IP>'
Test-NetConnection -TraceRoute $dest