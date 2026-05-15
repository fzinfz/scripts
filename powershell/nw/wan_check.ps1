. $PSScriptRoot\..\Lib.ps1

# ─── WAN IP 查询 ──────────────────────────────

<#
.SYNOPSIS
    查询当前 WAN IP 地址
.PARAMETER SiteIndex
    0（默认）= ipinfo.io; 1 = ifconfig.me
.OUTPUTS
    [string] WAN IP 地址，若获取失败返回 $null
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
            $site = 'http://ipinfo.io'
            $raw  = (Invoke-WebRequest $site -UseBasicParsing).Content
            $ip   = ($raw | ConvertFrom-Json).ip
        }
    }

    Write-Info "WAN IP from $site : $raw"
    if ($ip -match $Script:pattern_ip) { return $ip }
    return $null
}

Write-Step '默认路由'
Invoke-Steps @'
Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Format-Table -AutoSize
'@

$wanip = Get-WanIp

if ($null -ne $wanip) {
    Write-Tip "Test-NetConnection -TraceRoute $wanip | select InterfaceAlias, InterfaceIndex, SourceAddress, TraceRoute"
    Invoke-Step "tracert $wanip"
}
else {
    Write-Warn '无法获取 WAN IP 地址，跳过 TraceRoute 步骤'
}