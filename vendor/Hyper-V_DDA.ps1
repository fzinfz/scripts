$vmName = 'Win10ent'
$instanceId = '*VEN_1002&DEV_AA01*'
$ErrorActionPreference = 'Stop'
$vm = Get-VM -Name $vmName
$dev = (Get-PnpDevice -PresentOnly).Where{ $_.InstanceId -like $instanceId }
if (@($dev).Count -eq 1) {


Disable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false
$locationPath = (Get-PnpDeviceProperty -KeyName DEVPKEY_Device_LocationPaths -InstanceId $dev.InstanceId).Data[0]
Dismount-VmHostAssignableDevice -LocationPath $locationPath -Force -Verbose
Set-VM -VM $vm -DynamicMemory -MemoryMinimumBytes 3024MB -MemoryMaximumBytes 4096MB -MemoryStartupBytes 3024MB -AutomaticStopAction TurnOff

# If you want to play with GPUs:
Set-VM -VM $vm -StaticMemory -MemoryStartupBytes 3024MB -AutomaticStopAction TurnOff
Set-VM -VM $vm -GuestControlledCacheTypes $true -LowMemoryMappedIoSpace 3024MB -HighMemoryMappedIoSpace 4096MB -Verbose

Add-VMAssignableDevice -VM $vm -LocationPath $locationPath -Verbose

} else {

$dev | Sort-Object -Property Class | Format-Table -AutoSize
Write-Error -Message ('Number of devices: {0}' -f @($dev).Count)
}