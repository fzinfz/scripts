<#
.SYNOPSIS
    Batch fix ps1 file encoding: add UTF-8 BOM to files without BOM
.DESCRIPTION
    Scans all .ps1 files in the specified directory:
    - Already UTF-8 with BOM -> skip
    - Valid UTF-8 without BOM -> add BOM only
    - GBK/ANSI -> convert to UTF-8 with BOM
    PowerShell 5.x on Chinese Windows interprets BOM-less files as GBK, causing garbled Chinese text.
.NOTES
    After running, the scan path is printed and can be modified; press Enter to confirm.
    After scanning, the BOM status of the first 3 / last 3 files is printed.
    If there are files to fix, press Enter to continue.
#>

# ── Step 0: Interactive confirmation of scan path ──
$Path = Split-Path $PSScriptRoot -Parent

while ($true) {
    Write-Host "`nScan root directory: " -NoNewline -ForegroundColor Cyan
    Write-Host $Path -ForegroundColor Yellow
    $answer = Read-Host 'Press Enter to confirm, or enter a new path'
    if (-not $answer) { break }
    if (Test-Path $answer -PathType Container) {
        $Path = $answer
        break
    }
    Write-Host "  [!] Path does not exist: $answer" -ForegroundColor Red
}

# ── Detect BOM type ──
function Get-FileBOM {
    param([string]$FilePath)
    $bytes = Get-Content -Path $FilePath -Encoding Byte -TotalCount 4
    $hex = ($bytes | ForEach-Object { "{0:X2}" -f $_ }) -join " "

    switch ($hex) {
        { $_ -like "EF BB BF*" } { return "UTF-8 BOM" }
        { $_ -like "FF FE 00 00*" } { return "UTF-32 LE" }
        { $_ -like "FF FE*" } { return "UTF-16 LE" }
        { $_ -like "FE FF*" } { return "UTF-16 BE" }
        default { return "No BOM" }
    }
}

# ── Detect whether byte sequence is valid UTF-8 ──
function Test-ValidUTF8 {
    param([string]$FilePath)
    try {
        $bytes = [System.IO.File]::ReadAllBytes($FilePath)
        $enc = New-Object System.Text.UTF8Encoding($false, $true)
        $null = $enc.GetString($bytes)
        return $true
    } catch {
        return $false
    }
}

# ── Detect whether file contains Chinese text ──
function Test-HasChineseText {
    param([string]$FilePath)
    $content = [System.IO.File]::ReadAllText($FilePath)
    return $content -cmatch '[\u4e00-\u9fff]'
}

$utf8bom = New-Object System.Text.UTF8Encoding($true)
$gbk     = [System.Text.Encoding]::GetEncoding(936)

# ── Step 1: Scan all files and collect info ──
$files = @(Get-ChildItem $Path -Recurse -Filter '*.ps1' |
    Where-Object { $_.FullName -notmatch '\.workbuddy' })

$fileInfo = @()
$toFix    = @()

foreach ($f in $files) {
    $bomType = Get-FileBOM $f.FullName

    $fixType = switch ($bomType) {
        'UTF-8 BOM'   { 'OK' }
        'UTF-32 LE'   { 'SKIP' }
        'UTF-16 LE'   { 'SKIP' }
        'UTF-16 BE'   { 'SKIP' }
        'No BOM'      {
            if (Test-ValidUTF8 $f.FullName) {
                if (Test-HasChineseText $f.FullName) { 'U8' } else { 'SKIP-NO-CN' }
            } else {
                if (Test-HasChineseText $f.FullName) { 'GBK' } else { 'SKIP-NO-CN' }
            }
        }
    }

    $info = [PSCustomObject]@{
        File     = $f.FullName.Replace($Path + '\', '')
        BOM      = $bomType
        Type     = $fixType
        FullPath = $f.FullName
    }
    $fileInfo += $info
    if ($fixType -eq 'U8' -or $fixType -eq 'GBK') { $toFix += $info }
    if ($fixType -eq 'SKIP-NO-CN') { $info.Type = 'SKIP-NO-CN' }
}

# ── Step 2: Print BOM status of all Chinese files ──
$cnFiles = $fileInfo | Where-Object { $_.Type -ne 'SKIP-NO-CN' }

Write-Host "`nTotal $($files.Count) .ps1 files, $($cnFiles.Count) with Chinese text, need fixing: $($toFix.Count)`n" -ForegroundColor Yellow

if ($cnFiles.Count -gt 0) {
    Write-Host '--- All Chinese files BOM status ---' -ForegroundColor DarkCyan
    $cnFiles | ForEach-Object { Write-Host "  [$($_.BOM)] [$($_.Type)] $($_.File)" }
    Write-Host ""
}

# ── Step 3: Exit if no issues, otherwise prompt for confirmation ──
if ($toFix.Count -eq 0) {
    Write-Host 'All files BOM status is normal, no fix needed.' -ForegroundColor Green
    exit 0
}

Write-Host "Found $($toFix.Count) files need fixing, press Enter to start fixing..." -ForegroundColor Yellow
Read-Host | Out-Null

# ── Step 4: Perform fix ──
$fixed   = 0
$skipped = $files.Count - $toFix.Count

foreach ($info in $toFix) {
    if ($info.Type -eq 'U8') {
        $content = [System.IO.File]::ReadAllText($info.FullPath, [System.Text.Encoding]::UTF8)
        [System.IO.File]::WriteAllText($info.FullPath, $content, $utf8bom)
        Write-Host "[UTF8+BOM] $($info.File)" -ForegroundColor Cyan
    } else {
        $content = [System.IO.File]::ReadAllText($info.FullPath, $gbk)
        [System.IO.File]::WriteAllText($info.FullPath, $content, $utf8bom)
        Write-Host "[GBK->UTF8] $($info.File)" -ForegroundColor Green
    }
    $fixed++
}

Write-Host "`nDone. Fixed: $fixed | Skipped (already OK): $skipped" -ForegroundColor Yellow
