. .\Lib.ps1

run '
Get-StorageNode
Get-Disk | ft
gdr -PSProvider "FileSystem" | ft
Get-Volume | ft
'