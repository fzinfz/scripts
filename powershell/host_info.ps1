. .\Lib.ps1

run '
hostname
Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp | select InterfaceAlias, IPAddress, ValidLifetime
'