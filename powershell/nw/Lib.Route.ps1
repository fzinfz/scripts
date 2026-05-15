<#
.SYNOPSIS
    网络路由工具库
.DESCRIPTION
    提供默认路由查询相关的辅助函数，供 nw/ 目录内其他脚本引入。
.NOTES
    重构自: nw\Lib.Route.ps1
#>

. $PSScriptRoot\..\Lib.ps1

<#
.SYNOPSIS
    获取默认路由（0.0.0.0/0）列表
.OUTPUTS
    Microsoft.Management.Infrastructure.CimInstance[]
#>
function Get-DefaultRoute {
    Get-NetRoute -DestinationPrefix '0.0.0.0/0'
}

<#
.SYNOPSIS
    以 JSON 格式输出默认路由
#>
function Get-DefaultRouteJson {
    Get-DefaultRoute | ConvertTo-Json
}

<#
.SYNOPSIS
    获取默认路由的 RouteMetric 值列表
#>
function Get-DefaultRouteMetric {
    Get-DefaultRoute | ForEach-Object { $_.RouteMetric }
}
