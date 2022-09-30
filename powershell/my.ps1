Enable-WindowsOptionalFeature -Online -FeatureName "TelnetClient"

if (!(Test-Path $PROFILE.CurrentUserCurrentHost)){
    New-Item -ItemType Directory -Force -Path (Split-Path -parent $PROFILE.CurrentUserCurrentHost)
}
Copy-Item Profile.ps1 -Destination $PROFILE.CurrentUserCurrentHost -Force
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
