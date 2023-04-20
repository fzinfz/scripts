. ..\Lib.ps1

Get-Command -Module PnpDevice

tip Vm...
(Get-Command).Where{ $_.Name -like "*VMAssignableDevice*" }

tip VmHost...
(Get-Command).Where{ $_.Name -like "*VmHostAssignableDevice*" }

tip "Get-Command -Module Hyper-V"