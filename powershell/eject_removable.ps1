. .\Lib.ps1
check_volume

# https://learn.microsoft.com/en-us/windows/win32/api/shldisp/ne-shldisp-shellspecialfolderconstants
filter eject_volume() {
    $drive = (New-Object -comObject Shell.Application).Namespace(0x11).ParseName($_)
    if($drive){
        Write-Host -ForegroundColor Red "`nEjecting: $_"
        # $drive.InvokeVerb("Eject")
    }
}

gwmi win32_volume | ? { $_.DriveType -eq '2'} | select -ExpandPropert Name | eject_volume