. .\Lib.ps1

Get-ComputerInfo -Property Windows*, OsVersion, OsArchitecture, HyperVisorPresent `
| select -Property * -ExcludeProperty *Registered*

run '
(Get-WmiObject Win32_OperatingSystem).caption
Get-WmiObject Win32_Processor
$PROFILE | fl -Force
'

. .\EnvPath.lib.ps1
Show-EnvPath