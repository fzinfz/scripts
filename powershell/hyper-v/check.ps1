. ..\Lib.ps1

run '
Get-VM
Get-VMSwitch | ft
Get-VMHostAssignableDevice
'

get-vm | ? State -ne "Running" | % {
    tip '[Remove/Add]-VMAssignableDevice -LocationPath "$locationPath" -VMName $vm'
    Write-Host -ForegroundColor Green `n[TIP] Start-VM $_.Name
}

$file_survey_dda = "survey-dda.ps1"
if (!(Test-Path -Path $file_survey_dda )) {
    $wc = New-Object System.Net.WebClient
    $url = "https://raw.githubusercontent.com/Microsoft/Virtualization-Documentation/master/hyperv-samples/benarm-powershell/DDA/survey-dda.ps1"
    $wc.DownloadFile($url, $file_survey_dda)
}

tip "run survey-dda.ps1 first: https://learn.microsoft.com/en-us/virtualization/community/team-blog/2015/20151120-discrete-device-assignment-machines-and-devices"