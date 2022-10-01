. .\Lib.ps1

run "Get-NetRoute -DestinationPrefix 0.0.0.0/0"

$WAN1 = Get-NetRoute -NextHop 192.168.88.1
$WAN2 = Get-NetRoute -NextHop 192.168.98.1
$WAN3 = Get-NetRoute -NextHop 192.168.41.1

run 'Set-NetIPInterface -InterfaceIndex $WAN1.ifIndex -InterfaceMetric ( $WAN2.InterfaceMetric + 1 )'

if ($WAN3.ifIndex.Count -eq 1){ New-NetRoute -DestinationPrefix "192.168.1.0/24" -InterfaceIndex $WAN3.ifIndex -NextHop 192.168.41.1 }

run "Get-NetRoute | findstr 192"

run_ask .\net_check.ps1