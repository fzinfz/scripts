. .\Lib.ps1

Get-NetTCPConnection -State Listen | sort LocalPort `
| Select-Object -Property State, LocalAddress, LocalPort, @{'Name' = 'ProcessName';'Expression'={(Get-Process -Id $_.OwningProcess).Name}} ` | ft

run "netsh int ipv4 show dynamicportrange tcp"

tip "netsh int ipv4 set dynamicport tcp start=40000 num=25536"