. .\Lib.ps1

Get-ComputerInfo -Property Windows*, OsVersion, OsArchitecture, HyperVisorPresent `
| select -Property * -ExcludeProperty *Registered*

run '
(Get-WmiObject Win32_OperatingSystem).caption
Get-WmiObject Win32_Processor
$PROFILE | fl -Force
$PSVersionTable
'

. .\EnvPath.lib.ps1
Show-EnvPath


Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse `
| Get-ItemProperty -Name version -EA 0 `
| Where-Object { $_.PSChildName -Match '^(?!S)\p{L}'} `
| Select-Object PSPath, version