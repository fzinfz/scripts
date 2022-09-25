Enable-WindowsOptionalFeature -Online -FeatureName "TelnetClient"

if (!(Test-Path $PROFILE.CurrentUserCurrentHost)){
    $folder_CurrentUserCurrentHost = Split-Path -parent $PROFILE.CurrentUserCurrentHost
    New-Item -ItemType Directory -Force -Path $folder_CurrentUserCurrentHost
    Copy-Item *profile.ps1 -Destination $folder_CurrentUserCurrentHost
}
dir $PROFILE.CurrentUserCurrentHost

. .\EnvPath.lib.ps1
'
D:\sdk\flutter\bin
'.Split([Environment]::NewLine) | ? {$_.trim() -ne "" } | % { Add-EnvPath User $_ }

Get-Childitem  -Directory d:\sdk\*\bin | % { Add-EnvPath User $_ }

. .\check_env.ps1

New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
    -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -PropertyType String -Force