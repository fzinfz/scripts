<#
.SYNOPSIS
    Disk and Storage Information Query Script
.DESCRIPTION
    Outputs in order:
    - StorageNode
    - Physical Disks (Disk)
    - File System Drives (FileSystem PSDrive)
    - Volume Information (Volume)
    - Win32_Volume (including DriveType)
.NOTES
    Refactored from: disk.ps1
#>

. $PSScriptRoot\..\Lib.ps1

Write-Step 'Disk and Storage Information'
Invoke-Steps {
    Get-StorageNode | Format-Table -AutoSize
    Get-Disk | Format-Table -AutoSize
    Get-PSDrive -PSProvider FileSystem | Format-Table -AutoSize
    Get-Volume | Format-Table -AutoSize
}

Write-Step 'Volume Type Details'
Show-Volumes
