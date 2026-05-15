<#
.SYNOPSIS
    Hyper-V 虚拟机及 DDA 设备状态检查
.DESCRIPTION
    - 列出所有 VM 及其状态
    - 列出 VMSwitch
    - 列出宿主机可分配设备
    - 对非 Running 状态的 VM 输出提示
    - 按需下载 survey-dda.ps1 工具
.NOTES
    重构自: hyper-v\check.ps1
    需要以管理员身份运行
    DDA 参考: https://learn.microsoft.com/en-us/virtualization/community/team-blog/2015/20151120-discrete-device-assignment-machines-and-devices
#>

#Requires -RunAsAdministrator

. $PSScriptRoot\..\Lib.ps1

# ─── VM 基本信息 ──────────────────────────────
Write-Step 'Hyper-V 虚拟机与交换机'
Invoke-Steps @'
Get-VM | Format-Table -AutoSize
Get-VMSwitch | Format-Table -AutoSize
Get-VMHostAssignableDevice | Format-Table -AutoSize
'@

# ─── 非 Running VM 提示 ────────────────────────
Get-VM | Where-Object { $_.State -ne 'Running' } | ForEach-Object {
    Write-Tip "[Remove/Add]-VMAssignableDevice -LocationPath `$locationPath -VMName $($_.Name)"
    Write-Tip "Start-VM $($_.Name)"
}

# ─── 下载 survey-dda.ps1 ──────────────────────
$_surveyScript = Join-Path $PSScriptRoot 'survey-dda.ps1'
if (-not (Test-Path -Path $_surveyScript)) {
    Write-Info '下载 survey-dda.ps1...'
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile(
        'https://raw.githubusercontent.com/Microsoft/Virtualization-Documentation/master/hyperv-samples/benarm-powershell/DDA/survey-dda.ps1',
        $_surveyScript
    )
    Write-Info "已下载至: $_surveyScript"
}

Write-Tip "请先运行 survey-dda.ps1 以获取 DDA 设备 LocationPath"
Remove-Variable _surveyScript -ErrorAction SilentlyContinue
