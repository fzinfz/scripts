. .\Lib.ps1

Get-NetIPInterface -AddressFamily IPv4 | ? { $_.InterfaceAlias -notmatch "Loopback.*" } | sort -Property ifIndex
Get-NetIPAddress -AddressFamily IPv4 | sort -Property ifIndex | ft

Get-NetTCPConnection -State Listen | sort LocalPort `
| Select-Object -Property State, LocalAddress, LocalPort, @{'Name' = 'ProcessName';'Expression'={(Get-Process -Id $_.OwningProcess).Name}} `

run "netsh int ipv4 show dynamicportrange tcp"

tip "netsh int ipv4 set dynamicport tcp start=30000 num=20000"