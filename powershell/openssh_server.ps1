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

Get-WindowsCapability -Online | 
  Where-Object Name -like 'OpenSSH*' | 
  Where-Object State -eq 'NotPresent' |
  Select-Object -ExpandPropert Name |
  ForEach-Object {">>> Installing $_"; Add-WindowsCapability -Online -Name $_}

Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# (forked) Confirm the Firewall rule is configured. It should be created automatically by setup.
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}


$sshd_config = 'C:\ProgramData\ssh\sshd_config'
(Get-Content $sshd_config) -Replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes' | Set-Content $sshd_config
dir $sshd_config

# Set the sshd service to be started automatically
Get-Service -Name sshd | Set-Service -StartupType Automatic
Get-Service -Name sshd

# Start the sshd service
Start-Service sshd

# .pub key
$file_pub_key = "$env:USERPROFILE\.ssh\authorized_keys"
if (!(Test-Path $file_pub_key)){
    Write-Host -ForegroundColor Green "`n[TIP] create: $file_pub_key"
}
"`n"
$file_administrators_authorized_keys = "$env:ProgramData\ssh\administrators_authorized_keys"
if (!(Test-Path $file_administrators_authorized_keys)){
    Write-Host -ForegroundColor Green "`n[TIP] create: $file_administrators_authorized_keys"
}else{ 
    icacls.exe ""$file_administrators_authorized_keys"" /inheritance:r /grant ""Administrators:F"" /grant ""SYSTEM:F""
}

Write-Host -ForegroundColor Green "`n[TIP] run: Restart-Service sshd"
Get-ChildItem $env:USERPROFILE\.ssh, C:\ProgramData\ssh | 
  Select-Object Mode, FullName, Length, LastWriteTime | Format-Table -AutoSize 