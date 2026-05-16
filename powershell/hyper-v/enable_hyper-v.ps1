<#
.SYNOPSIS
    启用 Hyper-V 功能
.DESCRIPTION
    通过 Enable-WindowsOptionalFeature 和 DISM 两种方式启用 Hyper-V
.NOTES
    重构自: hyper-v\enable_hyper-v.ps1
    需要以管理员身份运行，执行后需重启
#>

#Requires -RunAsAdministrator

. $PSScriptRoot\..\Lib.ps1

Write-Step '启用 Hyper-V（PowerShell 方式）'
Invoke-Steps { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All }

Write-Step '启用 Hyper-V（DISM 方式）'
Invoke-Steps { DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V }

Write-Tip '启用完成后需要重启系统。'
