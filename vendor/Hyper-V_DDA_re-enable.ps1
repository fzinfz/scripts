# Remove all devices from a single VM
Remove-VMAssignableDevice -VMName win10ent -Verbose

# Return all to host
Get-VMHostAssignableDevice | Mount-VmHostAssignableDevice -Verbose

# Enable it in devmgmt.msc
(Get-PnpDevice -PresentOnly).Where{ $_.InstanceId -match 'VEN_1002&DEV_68A9' } |
Enable-PnpDevice -Confirm:$false -Verbose