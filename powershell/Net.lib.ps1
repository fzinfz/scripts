. .\Lib.ps1

$pattern_ip = '\d+\.\d+\.\d+\.\d+'

# unstable: http://myip.ipip.net

function check_net_wan_ip_1{
    run '(curl "http://ifconfig.me" -UseBasicParsing).Content' | Tee-Object -Variable myip_text
    return ($myip_text.Content | Select-String -Pattern $pattern_ip | Select Matches).Matches.Value
}

function check_net_wan_ip_2{
    $myip_obj = (curl "http://ipinfo.io" -UseBasicParsing).Content | ConvertFrom-Json
    return ($myip_obj.ip)
}

function check_net_wan{
    run "Get-NetRoute -DestinationPrefix 0.0.0.0/0"

    $myip = check_net_wan_ip_2
    if ($myip -match $pattern_ip){ run "Test-NetConnection -TraceRoute $myip | select InterfaceAlias, InterfaceIndex, SourceAddress, TraceRoute | fl -Force" }
}