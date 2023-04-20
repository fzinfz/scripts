. ..\Lib.ps1

$keyword = Read-Host -Prompt "`nKeyword in FriendlyName"

function search_pnp($keyword){
    (Get-PnpDevice).Where{ $_.FriendlyName -like "*$keyword*" }
}

search_pnp($keyword) | ft
search_pnp($keyword) | fl

if ( (search_pnp($keyword) | Measure-Object).Count -ne 1){
    Exit
}

$dev = search_pnp($keyword)
$dev_id = $dev.InstanceId

if ($dev.Status -eq "OK"){
    tip "Disable-PnpDevice -InstanceId $dev_id"
    Disable-PnpDevice -InstanceId "$dev_id"
}

# https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/deploy/deploying-graphics-devices-using-dda#example

$locationPath = (Get-PnpDeviceProperty -KeyName DEVPKEY_Device_LocationPaths -InstanceId $dev_id).Data[0]
tip "Dismount-VmHostAssignableDevice -LocationPath $locationPath -Force -Verbose"
Dismount-VmHostAssignableDevice -LocationPath $locationPath -Force -Verbose