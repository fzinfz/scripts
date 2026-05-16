# ============================================================
# encoding.ps1  —  Show and change PowerShell encoding settings
# Usage:
#   . .\encoding.ps1          # dot-source to persist in current session
#   .\encoding.ps1            # run standalone (changes are scoped to the child process)
# ============================================================

function Show-Encoding {
    Write-Host "`n=== Current Encoding Settings ===" -ForegroundColor Cyan
    Write-Host "  [1] OutputEncoding (pipe/stdout) : $($OutputEncoding.EncodingName)  (CP $($OutputEncoding.CodePage))" -ForegroundColor Yellow
    Write-Host "  [2] Console.OutputEncoding       : $([Console]::OutputEncoding.EncodingName)  (CP $([Console]::OutputEncoding.CodePage))" -ForegroundColor Yellow
    Write-Host "  [3] Console.InputEncoding         : $([Console]::InputEncoding.EncodingName)  (CP $([Console]::InputEncoding.CodePage))" -ForegroundColor Yellow

    $fileEnc = $PSDefaultParameterValues['*:Encoding']
    if ($null -eq $fileEnc) { $fileEnc = '(not set, defaults vary by cmdlet)' }
    Write-Host "  [4] PSDefaultParameterValues Encoding : $fileEnc" -ForegroundColor Yellow

    $chcp = & chcp 2>$null
    Write-Host "  [5] Active Code Page (chcp)       : $chcp" -ForegroundColor Yellow
    Write-Host ""
}

function Set-UTF8Encoding {
    <#
    .SYNOPSIS
        Switch the current session to UTF-8 across all encoding layers.
    .PARAMETER NoBOM
        When specified, sets file-writing cmdlets to UTF-8 without BOM (utf8NoBOM).
        Only available in PowerShell 6+. Ignored on Windows PowerShell 5.x.
    #>
    param([switch]$NoBOM)

    # Layer 1: pipe / stdout encoding
    $global:OutputEncoding = [System.Text.Encoding]::UTF8

    # Layer 2: console output & input
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8

    # Layer 3: file-writing cmdlets (Out-File, Set-Content, Export-Csv …)
    if ($PSVersionTable.PSVersion.Major -ge 6 -and $NoBOM) {
        $global:PSDefaultParameterValues['*:Encoding'] = 'utf8NoBOM'
    } else {
        $global:PSDefaultParameterValues['*:Encoding'] = 'utf8'
    }

    # Layer 4: change active code page (affects child processes like git, python, etc.)
    & chcp 65001 | Out-Null

    Write-Host "Encoding switched to UTF-8." -ForegroundColor Green
    Show-Encoding
}

function Set-GBKEncoding {
    <#
    .SYNOPSIS
        Switch the current session to GBK (CP936) — useful for legacy Chinese tools.
    #>
    $global:OutputEncoding = [System.Text.Encoding]::GetEncoding(936)
    [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(936)
    [Console]::InputEncoding  = [System.Text.Encoding]::GetEncoding(936)
    $global:PSDefaultParameterValues['*:Encoding'] = 'default'

    & chcp 936 | Out-Null

    Write-Host "Encoding switched to GBK (CP936)." -ForegroundColor Green
    Show-Encoding
}

# --- Main: show current state, then switch to UTF-8 by default ---
Show-Encoding
Set-UTF8Encoding
