<#
.SYNOPSIS
    Dismount PnP Device from Host and Assign to Hyper-V VM (DDA)
.DESCRIPTION
    1. Search PnP device by keyword
    2. If exactly one match is found, disable the device
    3. Get device LocationPath
    4. Execute Dismount-VmHostAssignableDevice
.NOTES
    Refactored from: hyper-v\pnp_dismount.ps1
    Requires running as administrator
    Reference: https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/deploy/deploying-graphics-devices-using-dda#example
#>

#Requires -RunAsAdministrator

. $PSScriptRoot\..\Lib.ps1

# --- Search Device --------------------------------

<#
.SYNOPSIS
    Fuzzy search PnP devices by FriendlyName
.PARAMETER Keyword
    Search keyword
#>
function Search-PnpByKeyword {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Keyword
    )
    (Get-PnpDevice).Where{ $_.FriendlyName -like "*$Keyword*" }
}

$keyword = Read-Host -Prompt 'PnP device FriendlyName keyword'
Assert-Param -Value $keyword -Name 'keyword'

$devices = Search-PnpByKeyword -Keyword $keyword
$devices | Format-Table -AutoSize
$devices | Format-List

$count = ($devices | Measure-Object).Count
if ($count -ne 1) {
    Write-Warn "Found $count matching devices; exactly one match is required to continue."
    exit 1
}

# --- Disable Device --------------------------------
$dev    = $devices
$devId  = $dev.InstanceId

if ($dev.Status -eq 'OK') {
    Write-Step "Disabling device: $devId"
    Write-Tip "Disable-PnpDevice -InstanceId $devId"
    Disable-PnpDevice -InstanceId $devId -Confirm:$false
}

# --- Get LocationPath and Dismount ----------------
$locationPath = (Get-PnpDeviceProperty `
    -KeyName DEVPKEY_Device_LocationPaths `
    -InstanceId $devId).Data[0]

Write-Step "Dismounting device: $locationPath"
Write-Tip "Dismount-VmHostAssignableDevice -LocationPath $locationPath -Force -Verbose"
Dismount-VmHostAssignableDevice -LocationPath $locationPath -Force -Verbose
