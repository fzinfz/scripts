<#
.SYNOPSIS
    Hyper-V VM and DDA Device Status Check
.DESCRIPTION
    - Lists all VMs and their status
    - Lists VMSwitch
    - Lists host assignable devices
    - Outputs tips for VMs not in Running state
    - Downloads survey-dda.ps1 tool on demand
.NOTES
    Refactored from: hyper-v\check.ps1
    Requires running as administrator
    DDA reference: https://learn.microsoft.com/en-us/virtualization/community/team-blog/2015/20151120-discrete-device-assignment-machines-and-devices
#>

#Requires -RunAsAdministrator

. $PSScriptRoot\..\Lib.ps1

# --- VM Basic Information -----------------------------
Write-Step 'Hyper-V VMs and Switches'
Invoke-Steps {
    Get-VM | Format-Table -AutoSize
    Get-VMSwitch | Format-Table -AutoSize
    Get-VMHostAssignableDevice | Format-Table -AutoSize
}

# --- Non-Running VM Tips ----------------------------
Get-VM | Where-Object { $_.State -ne 'Running' } | ForEach-Object {
    Write-Tip "[Remove/Add]-VMAssignableDevice -LocationPath `$locationPath -VMName $($_.Name)"
    Write-Tip "Start-VM $($_.Name)"
}

# --- Download survey-dda.ps1 ---------------------------
$_surveyScript = Join-Path $PSScriptRoot 'survey-dda.ps1'
if (-not (Test-Path -Path $_surveyScript)) {
    Write-Info 'Downloading survey-dda.ps1...'
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile(
        'https://raw.githubusercontent.com/Microsoft/Virtualization-Documentation/master/hyperv-samples/benarm-powershell/DDA/survey-dda.ps1',
        $_surveyScript
    )
    Write-Info "Downloaded to: $_surveyScript"
}

Write-Tip "Please run survey-dda.ps1 first to get the DDA device LocationPath"
Remove-Variable _surveyScript -ErrorAction SilentlyContinue
