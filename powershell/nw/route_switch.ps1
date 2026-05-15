<#
.SYNOPSIS
    交互式路由指标调整脚本
.DESCRIPTION
    1. 显示当前默认路由（0.0.0.0/0）
    2. 让用户选择目标接口 ifIndex
    3. 将该接口的 InterfaceMetric 设为当前最大值 - 1（提升优先级），
       其余接口 InterfaceMetric 设为当前最大值（降低优先级）
    4. RouteMetric 统一重置为当前最小值
.NOTES
    重构自: nw\route_switch.ps1
#>

. $PSScriptRoot\Lib.Route.ps1

# ─── 显示当前默认路由 ──────────────────────────
Write-Step '当前默认路由'
Get-DefaultRoute | Format-Table -AutoSize

# ─── 用户选择接口 ─────────────────────────────
$selectedIfIndex = Read-Host -Prompt "`n请输入要提升优先级的接口 ifIndex"
Assert-Param -Value $selectedIfIndex -Name 'ifIndex'
[int]$selectedIfIndex = $selectedIfIndex

# ─── 重置 RouteMetric 为最小值 ────────────────
$routeMetricMin = (Get-DefaultRouteMetric | Measure-Object -Minimum).Minimum
Write-Step "将所有默认路由的 RouteMetric 重置为 $routeMetricMin"
Invoke-Steps { Set-NetRoute -DestinationPrefix '0.0.0.0/0' -RouteMetric $routeMetricMin }

# ─── 调整 InterfaceMetric ─────────────────────
$ifMetricMax = (Get-DefaultRoute |
    ForEach-Object { $_.InterfaceMetric } |
    Measure-Object -Maximum).Maximum

Write-Step "其余接口 InterfaceMetric 设为 $ifMetricMax（降低优先级）"
Invoke-Steps { Set-NetIPInterface -InterfaceMetric $ifMetricMax }

Write-Step "接口 $selectedIfIndex 的 InterfaceMetric 设为 $($ifMetricMax - 1)（提升优先级）"
Invoke-Steps { Set-NetIPInterface -InterfaceIndex $selectedIfIndex -InterfaceMetric $($ifMetricMax - 1) }

# ─── 验证结果 ─────────────────────────────────
Write-Step '调整后默认路由'
Get-DefaultRoute | Format-Table -AutoSize
