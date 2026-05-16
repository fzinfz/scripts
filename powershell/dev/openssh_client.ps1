<#
.SYNOPSIS
    OpenSSH client configuration and ssh-agent management
.DESCRIPTION
    - Set ssh-agent service to auto-start and start it immediately
    - Display key files in the ~/.ssh directory
    - Output common SSH operation tips
.NOTES
    Refactored from: openssh_client.ps1
    Ref: https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement
    Tip: Profile.ps1 already handles automatic ssh-add loading
#>

. $PSScriptRoot\..\Lib.ps1

Write-Step 'ssh-agent service configuration'
Invoke-Steps {
    Get-Service ssh-agent | Set-Service -StartupType Automatic
    Start-Service ssh-agent
    Get-Service ssh-agent
}

Write-Step '~/.ssh key list'
Get-ChildItem -Path "$env:USERPROFILE\.ssh" -ErrorAction SilentlyContinue |
    Select-Object FullName, Length, LastWriteTime |
    Format-Table -AutoSize

Write-Tip @'
Common command examples:
    ssh-add $env:USERPROFILE\.ssh\id_rsa
    ssh root@127.0.0.1     # Note: use IP, do not use localhost
Profile.ps1 is configured to automatically run ssh-add on startup
'@
