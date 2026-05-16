<#
.SYNOPSIS
    System environment initialization and configuration script
.DESCRIPTION
    Run once to complete the following tasks:
    1. Enable Telnet Client optional feature
    2. Deploy Profile.ps1 to current user''s PowerShell Profile path
    3. Append SDK directories to User PATH
    4. Set OpenSSH default Shell to PowerShell
    5. Print environment variable overview
.NOTES
    Refactored from: my.ps1
    Requires administrator privileges (Enable-WindowsOptionalFeature and registry write need elevation)
#>

#Requires -RunAsAdministrator

. $PSScriptRoot\..\Lib.ps1
. $PSScriptRoot\..\EnvPath.ps1

# --- 1. Optional Features ---------------------------------------------------
Write-Step 'Enable Telnet Client'
Invoke-Steps { Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient }

# --- 2. Deploy Profile ------------------------------------------------------
Write-Step 'Deploy PowerShell Profile'
$_profileDir = Split-Path -Parent $PROFILE.CurrentUserCurrentHost
if (-not (Test-Path -Path $_profileDir)) {
    New-Item -ItemType Directory -Force -Path $_profileDir | Out-Null
}
$_profileSrc = Join-Path $PSScriptRoot '..\Profile.ps1'
Copy-Item -Path $_profileSrc -Destination $PROFILE.CurrentUserCurrentHost -Force
Write-Info "Profile copied to: $($PROFILE.CurrentUserCurrentHost)"
Get-Item $PROFILE.CurrentUserCurrentHost | Select-Object FullName, LastWriteTime | Format-Table -AutoSize
Remove-Variable _profileDir, _profileSrc -ErrorAction SilentlyContinue

# --- 3. Append SDK paths to User PATH ---------------------------------------
Write-Step 'Append SDK bin directories to User PATH'

# Explicitly specified path list
@(
    'D:\sdk\flutter\bin'
) | ForEach-Object { Add-EnvPath -EnvVarTarget User -Path $_ }

# Auto-discover d:\sdk\*\bin
Get-ChildItem -Directory 'D:\sdk\*\bin' -ErrorAction SilentlyContinue |
    ForEach-Object { Add-EnvPath -EnvVarTarget User -Path $_.FullName }

# --- 4. Set OpenSSH Default Shell -------------------------------------------
Write-Step 'Set OpenSSH Default Shell'
New-ItemProperty `
    -Path 'HKLM:\SOFTWARE\OpenSSH' `
    -Name DefaultShell `
    -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' `
    -PropertyType String `
    -Force | Out-Null
Write-Info 'OpenSSH DefaultShell set to powershell.exe'

# --- 5. Environment Check ---------------------------------------------------
Write-Step 'Environment Check'
. $PSScriptRoot\check_env.ps1