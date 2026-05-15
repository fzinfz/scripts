<#
.SYNOPSIS
    PowerShell Profile 初始化脚本
.DESCRIPTION
    在 PowerShell 启动时自动执行：
    - 切换工作目录到脚本根目录
    - 自动加载 SSH 私钥（若存在）
.NOTES
    重构自: Profile.ps1
    部署方式: 由 system\setup.ps1 复制到 $PROFILE.CurrentUserCurrentHost
#>

Set-Location -Path $PSScriptRoot

# ─── SSH 密钥自动加载 ────────────────────────
$_sshKey = Join-Path $env:USERPROFILE '.ssh\id_rsa'
if (Test-Path -Path $_sshKey) {
    # 只在尚未加载时才执行 ssh-add
    if ($null -eq (ssh-add -l | Select-String 'id_rsa')) {
        ssh-add $_sshKey
    }
    ssh-add -l
}
Remove-Variable _sshKey -ErrorAction SilentlyContinue
