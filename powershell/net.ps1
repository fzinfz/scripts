Get-NetIPInterface -AddressFamily IPv4 | ? { $_.InterfaceAlias -notmatch "Loopback.*" } | sort -Property ifIndex
Get-NetIPAddress -AddressFamily IPv4 | sort -Property ifIndex | ft