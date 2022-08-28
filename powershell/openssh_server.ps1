# https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=gui

# Pre-check

$PSVersionTable.PSVersion

$PSVersion_Major = $PSVersionTable.PSVersion | Select-Object -ExpandPropert Major
$PSVersion_Minor = $PSVersionTable.PSVersion | Select-Object -ExpandPropert Minor
$PSVersion = "$PSVersion_Major.$PSVersion_Minor" -as [double]
""; if ($PSVersion -lt 5.1) {throw "!!! PSVersion >= 5.1 required"}

if (!(
    New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()       )
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator
)) {throw "!!! not in the built-in Administrators group"}

# Install

Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*' | Where-Object State -eq 'NotPresent' |
  ForEach-Object {"Installing $_"; Add-WindowsCapability -Online -Name $_}

Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*' | Where-Object State -eq 'Installed'

# Start the sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# (forked) Confirm the Firewall rule is configured. It should be created automatically by setup.
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}