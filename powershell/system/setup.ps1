<#
.SYNOPSIS
    系统环境初始化与配置脚本
.DESCRIPTION
    一次性运行，完成以下工作：
    1. 启用 Telnet 客户端可选功能
    2. 部署 Profile.ps1 到当前用户的 PowerShell Profile 路径
    3. 追加 SDK 目录到 User PATH
    4. 设置 OpenSSH 默认 Shell 为 PowerShell
    5. 打印环境变量概览
.NOTES
    重构自: my.ps1
    需要以管理员身份运行（Enable-WindowsOptionalFeature、Registry 写入需要提权）
#>

#Requires -RunAsAdministrator

. $PSScriptRoot\..\Lib.ps1
. $PSScriptRoot\..\EnvPath.ps1

# ─── 1. 可选功能 ─────────────────────────────
Write-Step '启用 Telnet 客户端'
Invoke-Steps { Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient }

# ─── 2. 部署 Profile ─────────────────────────
Write-Step '部署 PowerShell Profile'
$_profileDir = Split-Path -Parent $PROFILE.CurrentUserCurrentHost
if (-not (Test-Path -Path $_profileDir)) {
    New-Item -ItemType Directory -Force -Path $_profileDir | Out-Null
}
$_profileSrc = Join-Path $PSScriptRoot '..\Profile.ps1'
Copy-Item -Path $_profileSrc -Destination $PROFILE.CurrentUserCurrentHost -Force
Write-Info "Profile 已复制到: $($PROFILE.CurrentUserCurrentHost)"
Get-Item $PROFILE.CurrentUserCurrentHost | Select-Object FullName, LastWriteTime | Format-Table -AutoSize
Remove-Variable _profileDir, _profileSrc -ErrorAction SilentlyContinue

# ─── 3. 追加 SDK 路径到 User PATH ────────────
Write-Step '追加 SDK bin 目录到 User PATH'

# 明确指定路径列表
@(
    'D:\sdk\flutter\bin'
) | ForEach-Object { Add-EnvPath -EnvVarTarget User -Path $_ }

# 自动发现 d:\sdk\*\bin
Get-ChildItem -Directory 'D:\sdk\*\bin' -ErrorAction SilentlyContinue |
    ForEach-Object { Add-EnvPath -EnvVarTarget User -Path $_.FullName }

# ─── 4. 设置 OpenSSH 默认 Shell ───────────────
Write-Step '设置 OpenSSH 默认 Shell'
New-ItemProperty `
    -Path 'HKLM:\SOFTWARE\OpenSSH' `
    -Name DefaultShell `
    -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' `
    -PropertyType String `
    -Force | Out-Null
Write-Info 'OpenSSH DefaultShell 已设置为 powershell.exe'

# ─── 5. 检查环境概览 ──────────────────────────
Write-Step '环境检查'
. $PSScriptRoot\check_env.ps1
