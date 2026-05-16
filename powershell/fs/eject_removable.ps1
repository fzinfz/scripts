<#
.SYNOPSIS
    弹出所有可移动磁盘脚本
.DESCRIPTION
    列出所有卷，然后弹出所有类型为可移动磁盘（DriveType=2）的卷。
.NOTES
    重构自: eject_removable.ps1
    参考：
    - DriveType: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/aa394515(v=vs.85)
    - Shell Namespace CLSID: https://learn.microsoft.com/en-us/windows/win32/api/shldisp/ne-shldisp-shellspecialfolderconstants
.WARNING
    $drive.InvokeVerb("Eject") 已弃用，请阅读注释以正确执行弹出操作。
#>

. $PSScriptRoot\disk.ps1

<#
.SYNOPSIS
    弹出指定驱动器盘符
.PARAMETER DriveName
    驱动器盘符，例如 'E:\'
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
            Write-Host -ForegroundColor Red "`n弹出: $DriveName"
            $drive.InvokeVerb('Eject')
        }
        else {
            Write-Warn "未找到驱动器: $DriveName"
        }
    }
}

Write-Step '弹出所有可移动磁盘（DriveType=2）'
Get-WmiObject Win32_Volume |
    Where-Object { $_.DriveType -eq 2 } |
    Select-Object -ExpandProperty Name |
    Invoke-EjectVolume
