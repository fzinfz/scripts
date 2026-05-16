<#
.SYNOPSIS
    PnP Device Query and Management Tool
.DESCRIPTION
    Lists PnP devices with status OK in specified device classes,
    and outputs command examples for disabling devices.
.NOTES
    Refactored from: pnp.ps1
    Supported device classes: Keyboard, Mouse, Bluetooth, USB, and all other PnP classes
#>

. $PSScriptRoot\..\Lib.ps1

<#
.SYNOPSIS
    List PnP devices with Status=OK in specified classes
.PARAMETER Classes
    Array of device class names, e.g. @('Keyboard', 'Mouse')
#>
function Show-PnpDevices {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Classes
    )

    foreach ($class in $Classes) {
        Write-Step "PnP Device - $class"
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
Example to disable a specific device:
    $device = Get-PnpDevice -Class Keyboard | Where-Object { $_.Name -like '*<keyword>*' }
    Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
'@
