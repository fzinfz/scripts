<#
.SYNOPSIS
    Enable Hyper-V Feature
.DESCRIPTION
    Enables Hyper-V via both Enable-WindowsOptionalFeature and DISM methods
.NOTES
    Refactored from: hyper-v\enable_hyper-v.ps1
    Requires running as administrator; reboot required after execution
#>

#Requires -RunAsAdministrator

. $PSScriptRoot\..\Lib.ps1

Write-Step 'Enable Hyper-V (PowerShell Method)'
Invoke-Steps { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All }

Write-Step 'Enable Hyper-V (DISM Method)'
Invoke-Steps { DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V }

Write-Tip 'A system reboot is required after enabling.'
