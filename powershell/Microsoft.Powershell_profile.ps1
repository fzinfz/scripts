Set-Location D:\GitHub\scripts\powershell

if (Test-Path $env:USERPROFILE\.ssh\id_rsa){
    ssh-add $env:USERPROFILE\.ssh\id_rsa
    ssh-add -l
}

