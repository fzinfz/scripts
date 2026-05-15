<#
.SYNOPSIS
    OpenSSH 客户端配置与 ssh-agent 管理
.DESCRIPTION
    - 设置 ssh-agent 服务为自动启动并立即启动
    - 显示 ~/.ssh 目录下的密钥文件
    - 输出常用 SSH 操作提示
.NOTES
    重构自: openssh_client.ps1
    参考: https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement
    提示: Profile.ps1 已处理 ssh-add 自动加载
#>

. $PSScriptRoot\Lib.ps1

Write-Step 'ssh-agent 服务配置'
Invoke-Steps {
    Get-Service ssh-agent | Set-Service -StartupType Automatic
    Start-Service ssh-agent
    Get-Service ssh-agent
}

Write-Step '~/.ssh 密钥列表'
Get-ChildItem -Path "$env:USERPROFILE\.ssh" -ErrorAction SilentlyContinue |
    Select-Object FullName, Length, LastWriteTime |
    Format-Table -AutoSize

Write-Tip @'
常用命令示例:
    ssh-add $env:USERPROFILE\.ssh\id_rsa
    ssh root@127.0.0.1     # 注意：使用 IP，不要用 localhost
Profile.ps1 已配置启动时自动执行 ssh-add
'@
