. .\Init.lib.ps1

run '
$PROFILE | fl -Force
Get-WmiObject Win32_Processor
'

. .\EnvPath.lib.ps1
Show-EnvPath