. .\Net.lib.ps1

run 'Get-NetIPInterface -AddressFamily IPv4 | ? { $_.InterfaceAlias -notmatch "Loopback.*" } | sort -Property ifIndex | ft'
run 'Get-NetIPAddress -AddressFamily IPv4 | sort -Property ifIndex | ft'

run "Get-NetAdapter | sort Name | ft"

check_net_wan