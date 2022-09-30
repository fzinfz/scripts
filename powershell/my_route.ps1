. .\Lib.ps1

run "Get-NetRoute -DestinationPrefix 0.0.0.0/0"

$WAN1 = Get-NetRoute -NextHop 192.168.88.1
$WAN2 = Get-NetRoute -NextHop 192.168.77.1

run 'Set-NetIPInterface -InterfaceIndex $WAN1.ifIndex -InterfaceMetric ( $WAN2.InterfaceMetric + 1 )'

check_net_wan