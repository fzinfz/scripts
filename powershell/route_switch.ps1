. .\Lib.Route.ps1

route_print
$selected_ifIndex = Read-Host -Prompt "`nSelect ifIndex to change metric"

# reset RouteMetric
run "Set-NetRoute -RouteMetric (route_metric | measure -Minimum).Minimum"

# reset InterfaceMetric
$interfaceMetric_max = (route_print | % { $_.interfaceMetric } | measure -Maximum).Maximum
run "Set-NetIPInterface -InterfaceMetric ($interfaceMetric_max)"

# set selected InterfaceMetric
run "Set-NetIPInterface -InterfaceIndex $selected_ifIndex -InterfaceMetric ($interfaceMetric_max - 1)"
route_print
