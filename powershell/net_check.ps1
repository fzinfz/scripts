. .\Lib.ps1

run 'Get-NetIPInterface -AddressFamily IPv4 | ? { $_.InterfaceAlias -notmatch "Loopback.*" } | sort -Property ifIndex | ft'
run 'Get-NetIPAddress -AddressFamily IPv4 | sort -Property ifIndex | ft'

run "Get-NetAdapter | sort Name | ft"
run 'Get-NetAdapterPowerManagement -Name "*" | select DeviceSleepOnDisconnect, WakeOnMagicPacket, Name | sort Name | ft'

function check_net_wan_ip($site_index){
    switch($site_index){
        1 {
            # unstable: http://wanip.ipip.net
            $checkip_site = "http://ifconfig.me"
            $wanip_text = (curl $checkip_site -UseBasicParsing).Content
            $wanip = ($wanip_text | Select-String -Pattern $pattern_ip | Select Matches).Matches.Value
        }
        Default {
            $checkip_site = "http://ipinfo.io"
            $wanip_text = (curl $checkip_site -UseBasicParsing).Content
            $wanip = ($wanip_text | ConvertFrom-Json).ip
        }
    }
    Write-Information "`nwanip$i from curl $checkip_site : $wanip_text" -InformationAction Continue
    if ($wanip -match $pattern_ip){ return $wanip }
}

function check_net_wan_route{
    run "Get-NetRoute -DestinationPrefix 0.0.0.0/0 | ft"

    for ($i = 1; $i -le 3; $i++){
        $wanip = [Environment]::GetEnvironmentVariable("wanip$i", 'User')
        if ($null -eq $wanip){ $wanip = check_net_wan_ip}
        run "Test-NetConnection -TraceRoute $wanip | select InterfaceAlias, InterfaceIndex, SourceAddress, TraceRoute"
    }
}
check_net_wan_route