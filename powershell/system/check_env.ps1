<#
.SYNOPSIS
    System environment info check script
.DESCRIPTION
    Output the following info:
    - Windows version and architecture
    - WMI system info (OS, CPU)
    - PowerShell Profile path
    - PSVersion
    - PATH environment variable (all scopes)
    - .NET Framework version
.NOTES
    Refactored from: check_env.ps1
#>

. $PSScriptRoot\..\Lib.ps1
. $PSScriptRoot\..\EnvPath.ps1

# --- Windows Basic Info -----------------------------------------------------
Write-Step 'Windows Basic Info'
Get-ComputerInfo -Property Windows*, OsVersion, OsArchitecture, HyperVisorPresent |
    Select-Object -Property * -ExcludeProperty *Registered* |
    Format-List

# --- WMI Quick Info ---------------------------------------------------------
Write-Step 'WMI Quick Info'
Invoke-Steps {
    (Get-WmiObject Win32_OperatingSystem).Caption
    Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed
    $PROFILE | Format-List -Force
    $PSVersionTable
}

# --- PATH Environment Variable (All Scopes) ---------------------------------
Write-Step 'PATH Environment Variable (All Scopes)'
Show-EnvPath

# --- .NET Framework ---------------------------------------------------------
Write-Step '.NET Framework Version'
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse |
    Get-ItemProperty -Name version -ErrorAction SilentlyContinue |
    Where-Object { $_.PSChildName -match '^(?!S)\p{L}' } |
    Select-Object PSPath, version |
    Format-Table -AutoSize