<#
.SYNOPSIS
    Batch execute network check scripts
.DESCRIPTION
    Sequentially list and execute all *_check.ps1 scripts in the nw directory:
    1. Automatically execute the first script
    2. Display the next script name, wait for user to press Enter before executing
    3. Repeat until the last script finishes
.NOTES
    Executed in file name order
#>

. $PSScriptRoot\..\Lib.ps1

$checkFiles = Get-ChildItem -Path $PSScriptRoot -Filter '*_check.ps1' | Sort-Object Name

if ($checkFiles.Count -eq 0) {
    Write-Warn "No *_check.ps1 files found"
    return
}

for ($i = 0; $i -lt $checkFiles.Count; $i++) {
    $file = $checkFiles[$i]

    if ($i -eq 0) {
        Write-Step "[$($i + 1)/$($checkFiles.Count)] Executing: $($file.Name)"
        & $file.FullName
    }
    else {
        Write-Host -ForegroundColor Cyan "`n[$($i + 1)/$($checkFiles.Count)] Next: $($file.Name)"
        Invoke-StepsWithConfirm { & $file.FullName }
    }
}

Write-Step 'All check scripts completed'