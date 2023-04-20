. .\Lib.ps1

function route_print(){
    Get-NetRoute -DestinationPrefix 0.0.0.0/0
}
function route_print_json(){
    route_print | ConvertTo-Json
}
function route_metric(){
    route_print | % { $_.RouteMetric }
}
