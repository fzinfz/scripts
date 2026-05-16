<#
.SYNOPSIS
    Desktop Shortcut Batch Creation Tool
.DESCRIPTION
    Creates .lnk shortcuts on the desktop for executable files listed in $ExeFiles array.
    - Skips and prints a warning if the file does not exist.
    - Shortcut name is derived from the file name (without extension).
    - Icon is taken from the executable file itself.
.NOTES
    Refactored from: my\shortcut_desktop.ps1
    Usage: Modify the $ExeFiles array and run directly.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ────────────────────────────────────────────
#  Config — modify as needed
# ────────────────────────────────────────────

$ExeFiles = @(
    # Add full paths of executables to create shortcuts for, e.g.:
    # 'C:\Program Files\Google\Chrome\Application\chrome.exe'
    # 'C:\Windows\System32\notepad.exe'
    # 'C:\Windows\System32\calc.exe'
)

# ────────────────────────────────────────────
#  Main Flow
# ────────────────────────────────────────────

$desktopPath  = [Environment]::GetFolderPath('Desktop')
$shell        = New-Object -ComObject WScript.Shell
$createdCount = 0
$skippedCount = 0

Write-Host "Desktop path: $desktopPath" -ForegroundColor Cyan

foreach ($exePath in $ExeFiles) {
    if (Test-Path -Path $exePath) {
        $name         = [System.IO.Path]::GetFileNameWithoutExtension($exePath)
        $shortcutPath = Join-Path -Path $desktopPath -ChildPath "$name.lnk"

        $shortcut                  = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath       = $exePath
        $shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($exePath)
        $shortcut.IconLocation     = "$exePath,0"
        $shortcut.Save()

        Write-Host "[OK] $name" -ForegroundColor Green
        $createdCount++
    }
    else {
        Write-Warning "File not found: $exePath"
        $skippedCount++
    }
}

Write-Host ''
Write-Host "Done. Created: $createdCount   Skipped: $skippedCount" -ForegroundColor Cyan
