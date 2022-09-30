Set-Location D:\GitHub\scripts\powershell

$file_id_rsa = "$env:USERPROFILE\.ssh\id_rsa"
if (Test-Path $file_id_rsa){
    if ($null -eq (ssh-add -l|findstr id_rsa)){ ssh-add $file_id_rsa }
    ssh-add -l
}