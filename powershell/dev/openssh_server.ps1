<#
.SYNOPSIS
    OpenSSH 服务端安装与配置脚本
.DESCRIPTION
    1. 检查 PowerShell 版本（>= 5.1）和管理员权限
    2. 安装缺失的 OpenSSH 功能组件
    3. 配置防火墙规则（port 22）
    4. 启用 PubkeyAuthentication
    5. 设置 sshd 服务自动启动并立即启动
    6. 检查 authorized_keys 文件是否存在并修复权限
    7. 显示 ~/.ssh 与 ProgramData/ssh 目录内容
.NOTES
    重构自: openssh_server.ps1
    参考: https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=gui
    需要以管理员身份运行
#>

#Requires -RunAsAdministrator

. $PSScriptRoot\..\Lib.ps1

# ─── 前置检查 ─────────────────────────────────
Write-Step '前置检查'

$psVersion = $PSVersionTable.PSVersion
Write-Info "PowerShell 版本: $psVersion"
if ($psVersion -lt [Version]'5.1') {
    throw '需要 PowerShell >= 5.1'
}

# ─── 安装 OpenSSH 功能 ────────────────────────
Write-Step '安装 OpenSSH 功能组件（仅安装缺失项）'
Get-WindowsCapability -Online |
    Where-Object { $_.Name -like 'OpenSSH*' -and $_.State -eq 'NotPresent' } |
    ForEach-Object {
        Write-Info "安装: $($_.Name)"
        Add-WindowsCapability -Online -Name $_.Name
    }

Write-Step '已安装的 OpenSSH 组件'
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*' | Format-Table -AutoSize

# ─── 防火墙规则 ───────────────────────────────
Write-Step '防火墙规则检查（OpenSSH-Server-In-TCP）'
if (-not (Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue)) {
    Write-Info '防火墙规则不存在，创建中...'
    New-NetFirewallRule `
        -Name 'OpenSSH-Server-In-TCP' `
        -DisplayName 'OpenSSH Server (sshd)' `
        -Enabled True `
        -Direction Inbound `
        -Protocol TCP `
        -Action Allow `
        -LocalPort 22 | Out-Null
    Write-Info '防火墙规则已创建。'
}
else {
    Write-Info "防火墙规则「OpenSSH-Server-In-TCP」已存在。"
}

# ─── PubkeyAuthentication ─────────────────────
Write-Step '启用 PubkeyAuthentication'
$sshdConfig = 'C:\ProgramData\ssh\sshd_config'
if (Test-Path -Path $sshdConfig) {
    (Get-Content $sshdConfig) -replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes' |
        Set-Content $sshdConfig
    Write-Info "已更新: $sshdConfig"
}
else {
    Write-Warn "sshd_config 不存在: $sshdConfig"
}

# ─── sshd 服务 ────────────────────────────────
Write-Step 'sshd 服务配置'
Invoke-Steps {
    Get-Service -Name sshd | Set-Service -StartupType Automatic
    Start-Service sshd
    Get-Service -Name sshd
}

# ─── authorized_keys 检查 ─────────────────────
Write-Step '公钥文件检查'

$userAuthKeys  = "$env:USERPROFILE\.ssh\authorized_keys"
$adminAuthKeys = "$env:ProgramData\ssh\administrators_authorized_keys"

if (-not (Test-Path $userAuthKeys)) {
    Write-Tip "请创建文件: $userAuthKeys"
}

if (Test-Path $adminAuthKeys) {
    Write-Step '修复 administrators_authorized_keys 权限'
    Invoke-Steps { icacls.exe "$adminAuthKeys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F" }
}
else {
    Write-Tip "如需管理员 SSH 登录，请创建: $adminAuthKeys"
}

# ─── 目录概览 ─────────────────────────────────
Write-Step 'SSH 密钥目录'
Get-ChildItem -Path "$env:USERPROFILE\.ssh", 'C:\ProgramData\ssh' -ErrorAction SilentlyContinue |
    Select-Object Mode, FullName, Length, LastWriteTime |
    Format-Table -AutoSize

# ─── 重启并查看事件 ───────────────────────────
Write-Step '重启 sshd 并查看最新事件'
Invoke-Steps {
    Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp | Sort-Object ifIndex | Format-Table -AutoSize
    Restart-Service sshd
    Get-WinEvent OpenSSH* | Select-Object -First 10 | Format-Table -AutoSize
}
