<#
.SYNOPSIS
    PowerShell Profile Initialization Script
.DESCRIPTION
    Automatically executed when PowerShell starts:
    - Changes working directory to the script root directory
    - Automatically loads SSH private keys (if they exist)
.NOTES
    Refactored from: Profile.ps1
    Deployment: Copied by system\setup.ps1 to $PROFILE.CurrentUserCurrentHost
#>

Set-Location -Path $PSScriptRoot

# ─── Auto-load SSH Keys ────────────────────────
$_sshKey = Join-Path $env:USERPROFILE '.ssh\id_rsa'
if (Test-Path -Path $_sshKey) {
    # Only run ssh-add if the key is not already loaded
    if ($null -eq (ssh-add -l | Select-String 'id_rsa')) {
        ssh-add $_sshKey
    }
    ssh-add -l
}
Remove-Variable _sshKey -ErrorAction SilentlyContinue
