. .\Lib.ps1

function get_pnp(){
    for($i =0; $i -lt $args.Length; $i++) {
        run "Get-PnpDevice -class $($args[$i]) | ? Status -eq 'OK' | sort InstanceId" | select Name, InstanceId
        ""
    }
}

get_pnp Keyboard Mouse Bluetooth USB
tip '$device = ; Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false'