<#
.SYNOPSIS
    PnP 设备查询与管理工具
.DESCRIPTION
    列出指定设备类别中状态为 OK 的 PnP 设备，
    并输出禁用设备的命令示例。
.NOTES
    重构自: pnp.ps1
    支持的设备类别: Keyboard, Mouse, Bluetooth, USB, 等所有 PnP 类别
#>

. $PSScriptRoot\..\Lib.ps1

<#
.SYNOPSIS
    列出指定类别中 Status=OK 的 PnP 设备
.PARAMETER Classes
    设备类别名称数组，例如 @('Keyboard', 'Mouse')
#>
function Show-PnpDevices {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Classes
    )

    foreach ($class in $Classes) {
        Write-Step "PnP 设备 - $class"
        Get-PnpDevice -Class $class -ErrorAction SilentlyContinue |
            Where-Object { $_.Status -eq 'OK' } |
            Sort-Object InstanceId |
            Select-Object Name, InstanceId |
            Format-Table -AutoSize
        ''
    }
}

Show-PnpDevices -Classes @('Keyboard', 'Mouse', 'Bluetooth', 'USB')

Write-Tip @'
禁用指定设备示例:
    $device = Get-PnpDevice -Class Keyboard | Where-Object { $_.Name -like '*<关键词>*' }
    Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
'@
