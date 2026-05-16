<#
.SYNOPSIS
    Network routing utility library
.DESCRIPTION
    Provides helper functions for default route queries, imported by other scripts in the nw/ directory.
.NOTES
    Refactored from: nw\Lib.Route.ps1
#>

. $PSScriptRoot\..\Lib.ps1

<#
.SYNOPSIS
    Get the list of default routes (0.0.0.0/0)
.OUTPUTS
    Microsoft.Management.Infrastructure.CimInstance[]
#>
function Get-DefaultRoute {
    Get-NetRoute -DestinationPrefix '0.0.0.0/0'
}

<#
.SYNOPSIS
    Output default routes in JSON format
#>
function Get-DefaultRouteJson {
    Get-DefaultRoute | ConvertTo-Json
}

<#
.SYNOPSIS
    Get the list of RouteMetric values for default routes
#>
function Get-DefaultRouteMetric {
    Get-DefaultRoute | ForEach-Object { $_.RouteMetric }
}