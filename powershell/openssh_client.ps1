# https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement

# private key
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
Get-Service ssh-agent

dir $env:USERPROFILE\.ssh | select FullName
Write-Host -ForegroundColor Green '
[TIP] gen key & cmd examples:
    ssh-add $env:USERPROFILE\.ssh\id_rsa
    ssh root@127.0.0.1 # no @localhost
'

# auto ssh-add in *profile.ps1