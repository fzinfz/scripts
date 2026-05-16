<#
.SYNOPSIS
    将 PnP 设备从宿主机卸载并分配给 Hyper-V VM（DDA）
.DESCRIPTION
    1. 通过关键词搜索 PnP 设备
    2. 若找到唯一匹配，禁用该设备
    3. 获取设备 LocationPath
    4. 执行 Dismount-VmHostAssignableDevice
.NOTES
    重构自: hyper-v\pnp_dismount.ps1
    需要以管理员身份运行
    参考: https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/deploy/deploying-graphics-devices-using-dda#example
#>

#Requires -RunAsAdministrator

. $PSScriptRoot\..\Lib.ps1

# ─── 搜索设备 ─────────────────────────────────

<#
.SYNOPSIS
    按 FriendlyName 模糊搜索 PnP 设备
.PARAMETER Keyword
    搜索关键词
#>
function Search-PnpByKeyword {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Keyword
    )
    (Get-PnpDevice).Where{ $_.FriendlyName -like "*$Keyword*" }
}

$keyword = Read-Host -Prompt 'PnP 设备 FriendlyName 关键词'
Assert-Param -Value $keyword -Name 'keyword'

$devices = Search-PnpByKeyword -Keyword $keyword
$devices | Format-Table -AutoSize
$devices | Format-List

$count = ($devices | Measure-Object).Count
if ($count -ne 1) {
    Write-Warn "找到 $count 个匹配设备，需唯一匹配才能继续。"
    exit 1
}

# ─── 禁用设备 ─────────────────────────────────
$dev    = $devices
$devId  = $dev.InstanceId

if ($dev.Status -eq 'OK') {
    Write-Step "禁用设备: $devId"
    Write-Tip "Disable-PnpDevice -InstanceId $devId"
    Disable-PnpDevice -InstanceId $devId -Confirm:$false
}

# ─── 获取 LocationPath 并卸载 ─────────────────
$locationPath = (Get-PnpDeviceProperty `
    -KeyName DEVPKEY_Device_LocationPaths `
    -InstanceId $devId).Data[0]

Write-Step "Dismount 设备: $locationPath"
Write-Tip "Dismount-VmHostAssignableDevice -LocationPath $locationPath -Force -Verbose"
Dismount-VmHostAssignableDevice -LocationPath $locationPath -Force -Verbose
