. $PSScriptRoot\..\Lib.ps1

# --- WAN IP Query -----------------------------------------------------------

<#
.SYNOPSIS
    Query current WAN IP address
.PARAMETER SiteIndex
    0 (default) = ipinfo.io; 1 = ifconfig.me
.OUTPUTS
    [string] WAN IP address, returns $null if failed
#>
function Get-WanIp {
    param(
        [ValidateRange(0, 1)]
        [int]$SiteIndex = 0
    )

    switch ($SiteIndex) {
        1 {
            $site = 'http://ifconfig.me'
            $raw  = (Invoke-WebRequest $site -UseBasicParsing).Content
            $ip   = ($raw | Select-String -Pattern $Script:pattern_ip |
                        Select-Object -ExpandProperty Matches).Value
        }
        default {
            $site = 'http://ipinfo.io/json'
            $ip   = (Invoke-RestMethod -Uri $site).ip
        }
    }

    Write-Info "WAN IP from $site"
    if ($ip -match $Script:pattern_ip) { return $ip }
    return $null
}

Write-Step 'Default Routes'
Invoke-Steps { Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Format-Table -AutoSize }

$wanip = Get-WanIp

if ($null -ne $wanip) {
    Write-Tip "Test-NetConnection -TraceRoute $wanip | select InterfaceAlias, InterfaceIndex, SourceAddress, TraceRoute"
    Invoke-Steps { tracert $wanip }
}
else {
    Write-Warn 'Failed to get WAN IP address. Skipping TraceRoute step.'
}