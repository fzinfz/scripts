<#
.SYNOPSIS
    Interactive route metric adjustment script
.DESCRIPTION
    1. Display current default routes (0.0.0.0/0)
    2. Let user select target interface ifIndex
    3. Set this interface''s InterfaceMetric to current max - 1 (raise priority),
       set other interfaces'' InterfaceMetric to current max (lower priority)
    4. Reset RouteMetric uniformly to current minimum
.NOTES
    Refactored from: nw\route_switch.ps1
#>

. $PSScriptRoot\Lib.Route.ps1

# --- Display current default routes -----------------------------------------
Write-Step 'Current Default Routes'
Get-DefaultRoute | Format-Table -AutoSize

# --- User selects interface -------------------------------------------------
$selectedIfIndex = Read-Host -Prompt "`nEnter the ifIndex of the interface to raise priority"
Assert-Param -Value $selectedIfIndex -Name 'ifIndex'
[int]$selectedIfIndex = $selectedIfIndex

# --- Reset RouteMetric to minimum -------------------------------------------
$routeMetricMin = (Get-DefaultRouteMetric | Measure-Object -Minimum).Minimum
Write-Step "Reset all default routes' RouteMetric to $routeMetricMin"
Invoke-Steps { Set-NetRoute -DestinationPrefix '0.0.0.0/0' -RouteMetric $routeMetricMin }

# --- Adjust InterfaceMetric -------------------------------------------------
$ifMetricMax = (Get-DefaultRoute |
    ForEach-Object { $_.InterfaceMetric } |
    Measure-Object -Maximum).Maximum

Write-Step "Set other interfaces' InterfaceMetric to $ifMetricMax (lower priority)"
Invoke-Steps { Set-NetIPInterface -InterfaceMetric $ifMetricMax }

Write-Step "Set interface $selectedIfIndex InterfaceMetric to $($ifMetricMax - 1) (raise priority)"
Invoke-Steps { Set-NetIPInterface -InterfaceIndex $selectedIfIndex -InterfaceMetric $($ifMetricMax - 1) }

# --- Verify results ---------------------------------------------------------
Write-Step 'Adjusted Default Routes'
Get-DefaultRoute | Format-Table -AutoSize