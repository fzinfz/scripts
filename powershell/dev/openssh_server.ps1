<#
.SYNOPSIS
    OpenSSH server installation and configuration script
.DESCRIPTION
    1. Check PowerShell version (>= 5.1) and administrator privileges
    2. Install missing OpenSSH feature components
    3. Configure firewall rules (port 22)
    4. Enable PubkeyAuthentication
    5. Set sshd service to auto-start and start it immediately
    6. Check if authorized_keys file exists and fix permissions
    7. Display contents of ~/.ssh and ProgramData/ssh directories
.NOTES
    Refactored from: openssh_server.ps1
    Ref: https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=gui
    Must be run as administrator
#>

#Requires -RunAsAdministrator

. $PSScriptRoot\..\Lib.ps1

# ─── Pre-checks ─────────────────────────────────
Write-Step 'Pre-checks'

$psVersion = $PSVersionTable.PSVersion
Write-Info "PowerShell version: $psVersion"
if ($psVersion -lt [Version]'5.1') {
    throw 'Requires PowerShell >= 5.1'
}

# ─── Install OpenSSH features ────────────────────────
Write-Step 'Install OpenSSH feature components (missing only)'
Get-WindowsCapability -Online |
    Where-Object { $_.Name -like 'OpenSSH*' -and $_.State -eq 'NotPresent' } |
    ForEach-Object {
        Write-Info "Installing: $($_.Name)"
        Add-WindowsCapability -Online -Name $_.Name
    }

Write-Step 'Installed OpenSSH components'
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*' | Format-Table -AutoSize

# ─── Firewall rules ───────────────────────────────
Write-Step 'Firewall rule check (OpenSSH-Server-In-TCP)'
if (-not (Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue)) {
    Write-Info 'Firewall rule does not exist, creating...'
    New-NetFirewallRule `
        -Name 'OpenSSH-Server-In-TCP' `
        -DisplayName 'OpenSSH Server (sshd)' `
        -Enabled True `
        -Direction Inbound `
        -Protocol TCP `
        -Action Allow `
        -LocalPort 22 | Out-Null
    Write-Info 'Firewall rule created.'
}
else {
    Write-Info "Firewall rule [OpenSSH-Server-In-TCP] already exists."
}

# ─── PubkeyAuthentication ─────────────────────
Write-Step 'Enable PubkeyAuthentication'
$sshdConfig = 'C:\ProgramData\ssh\sshd_config'
if (Test-Path -Path $sshdConfig) {
    (Get-Content $sshdConfig) -replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes' |
        Set-Content $sshdConfig
    Write-Info "Updated: $sshdConfig"
}
else {
    Write-Warn "sshd_config does not exist: $sshdConfig"
}

# ─── sshd service ────────────────────────────────
Write-Step 'sshd service configuration'
Invoke-Steps {
    Get-Service -Name sshd | Set-Service -StartupType Automatic
    Start-Service sshd
    Get-Service -Name sshd
}

# ─── authorized_keys check ─────────────────────
Write-Step 'Public key file check'

$userAuthKeys  = "$env:USERPROFILE\.ssh\authorized_keys"
$adminAuthKeys = "$env:ProgramData\ssh\administrators_authorized_keys"

if (-not (Test-Path $userAuthKeys)) {
    Write-Tip "Please create file: $userAuthKeys"
}

if (Test-Path $adminAuthKeys) {
    Write-Step 'Fix administrators_authorized_keys permissions'
    Invoke-Steps { icacls.exe "$adminAuthKeys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F" }
}
else {
    Write-Tip "For administrator SSH login, please create: $adminAuthKeys"
}

# ─── Directory overview ─────────────────────────────────
Write-Step 'SSH key directories'
Get-ChildItem -Path "$env:USERPROFILE\.ssh", 'C:\ProgramData\ssh' -ErrorAction SilentlyContinue |
    Select-Object Mode, FullName, Length, LastWriteTime |
    Format-Table -AutoSize

# ─── Restart and view events ───────────────────────────
Write-Step 'Restart sshd and view latest events'
Invoke-Steps {
    Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp | Sort-Object ifIndex | Format-Table -AutoSize
    Restart-Service sshd
    Get-WinEvent OpenSSH* | Select-Object -First 10 | Format-Table -AutoSize
}
