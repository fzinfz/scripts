<#
.SYNOPSIS
    Eject All Removable Disks Script
.DESCRIPTION
    Lists all volumes, then ejects all volumes with type Removable Disk (DriveType=2).
.NOTES
    Refactored from: eject_removable.ps1
    References:
    - DriveType: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/aa394515(v=vs.85)
    - Shell Namespace CLSID: https://learn.microsoft.com/en-us/windows/win32/api/shldisp/ne-shldisp-shellspecialfolderconstants
.WARNING
    $drive.InvokeVerb("Eject") is deprecated; read the comments to properly perform the eject operation.
#>

. $PSScriptRoot\disk.ps1

<#
.SYNOPSIS
    Eject Specified Drive Letter
.PARAMETER DriveName
    Drive letter, e.g. 'E:\'
#>
function Invoke-EjectVolume {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$DriveName
    )
    process {
        $shell = New-Object -ComObject Shell.Application
        # 0x11 = CLSID "This PC" Namespace
        $drive = $shell.Namespace(0x11).ParseName($DriveName)
        if ($drive) {
            Write-Host -ForegroundColor Red "`nEjecting: $DriveName"
            $drive.InvokeVerb('Eject')
        }
        else {
            Write-Warn "Drive not found: $DriveName"
        }
    }
}

Write-Step 'Eject All Removable Disks (DriveType=2)'
Get-WmiObject Win32_Volume |
    Where-Object { $_.DriveType -eq 2 } |
    Select-Object -ExpandProperty Name |
    Invoke-EjectVolume
