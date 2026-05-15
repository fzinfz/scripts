<#
.SYNOPSIS
    磁盘与存储信息查询脚本
.DESCRIPTION
    依次输出：
    - StorageNode
    - 物理磁盘（Disk）
    - 文件系统驱动器（FileSystem PSDrive）
    - 卷信息（Volume）
    - Win32_Volume（含 DriveType）
.NOTES
    重构自: disk.ps1
#>

. $PSScriptRoot\Lib.ps1

Write-Step '磁盘与存储信息'
Invoke-Steps @'
Get-StorageNode | Format-Table -AutoSize
Get-Disk | Format-Table -AutoSize
Get-PSDrive -PSProvider FileSystem | Format-Table -AutoSize
Get-Volume | Format-Table -AutoSize
'@

Write-Step '卷类型明细'
Show-Volumes
