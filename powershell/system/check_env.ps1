<#
.SYNOPSIS
    系统环境信息检查脚本
.DESCRIPTION
    输出以下信息：
    - Windows 版本与架构
    - WMI 系统信息（OS、CPU）
    - PowerShell Profile 路径
    - PSVersion
    - PATH 环境变量（所有作用域）
    - .NET Framework 版本
.NOTES
    重构自: check_env.ps1
#>

. $PSScriptRoot\..\Lib.ps1
. $PSScriptRoot\..\EnvPath.ps1

# ─── Windows 基本信息 ─────────────────────────
Write-Step 'Windows 基本信息'
Get-ComputerInfo -Property Windows*, OsVersion, OsArchitecture, HyperVisorPresent |
    Select-Object -Property * -ExcludeProperty *Registered* |
    Format-List

# ─── WMI 快速信息 ─────────────────────────────
Write-Step 'WMI 快速信息'
Invoke-Steps {
    (Get-WmiObject Win32_OperatingSystem).Caption
    Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed
    $PROFILE | Format-List -Force
    $PSVersionTable
}

# ─── PATH 环境变量 ────────────────────────────
Write-Step 'PATH 环境变量（所有作用域）'
Show-EnvPath

# ─── .NET Framework ───────────────────────────
Write-Step '.NET Framework 版本'
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse |
    Get-ItemProperty -Name version -ErrorAction SilentlyContinue |
    Where-Object { $_.PSChildName -match '^(?!S)\p{L}' } |
    Select-Object PSPath, version |
    Format-Table -AutoSize
