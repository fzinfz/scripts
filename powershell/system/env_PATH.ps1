<#
.SYNOPSIS
    Export or import PATH environment variable entries.

.DESCRIPTION
    /export
        Merge System PATH + User PATH, de-duplicate, sort alphabetically,
        and save to %USERPROFILE%\bak\PATH.txt (one path per line, UTF-8).

    /import
        1. First back up the current System + User PATH (merged, de-duped) to
           %USERPROFILE%\bak\PATH_bak.txt.
        2. Read %USERPROFILE%\bak\PATH.txt and add each entry to the User PATH,
           skipping any path that:
             - is already present in the current PATH_bak (sys or user), or
             - does not exist on disk.

.EXAMPLE
    .\env_PATH.ps1 /export
    .\env_PATH.ps1 /import
#>

param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('/export', '/import')]
    [string]$Action
)

$bakDir     = Join-Path $env:USERPROFILE 'bak'
$exportFile = Join-Path $bakDir 'PATH.txt'
$backupFile = Join-Path $bakDir 'PATH_bak.txt'

# ── helper: ensure bak dir exists ─────────────────────────────────────────────
function Ensure-BakDir {
    if (-not (Test-Path $bakDir)) {
        New-Item -ItemType Directory -Path $bakDir | Out-Null
        Write-Host "Created backup directory: $bakDir"
    }
}

# ── helper: read sys + user PATH, merge, de-dup, sort ─────────────────────────
function Get-MergedPath {
    $sys  = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine') -split ';'
    $user = [System.Environment]::GetEnvironmentVariable('PATH', 'User')    -split ';'
    return ($sys + $user) |
           Where-Object { $_ -ne '' } |
           Sort-Object -Unique   # case-insensitive unique + sort
}

# ─── /export ──────────────────────────────────────────────────────────────────
if ($Action -eq '/export') {

    $paths = Get-MergedPath

    Ensure-BakDir
    $paths | Set-Content -Path $exportFile -Encoding UTF8
    Write-Host "Exported $($paths.Count) path(s) to: $exportFile"
}

# ─── /import ──────────────────────────────────────────────────────────────────
elseif ($Action -eq '/import') {

    if (-not (Test-Path $exportFile)) {
        Write-Error "Import file not found: $exportFile"
        exit 1
    }

    Ensure-BakDir

    # Step 1 — back up current merged PATH to PATH_bak.txt
    $currentMerged = Get-MergedPath
    $currentMerged | Set-Content -Path $backupFile -Encoding UTF8
    Write-Host "Backed up current PATH ($($currentMerged.Count) entries) to: $backupFile"

    # Step 2 — read import list
    $importPaths = Get-Content -Path $exportFile -Encoding UTF8 |
                   Where-Object { $_ -ne '' } |
                   Select-Object -Unique

    # Build a fast lookup set from PATH_bak (case-insensitive)
    $bakSet = [System.Collections.Generic.HashSet[string]]::new(
                  [System.StringComparer]::OrdinalIgnoreCase)
    $currentMerged | ForEach-Object { [void]$bakSet.Add($_) }

    # Current User PATH (for appending)
    $userRaw   = [System.Environment]::GetEnvironmentVariable('PATH', 'User')
    $userPaths = $userRaw -split ';' | Where-Object { $_ -ne '' }

    $added = [System.Collections.Generic.List[string]]::new()

    foreach ($p in $importPaths) {

        # Skip if already in current sys/user PATH
        if ($bakSet.Contains($p)) {
            Write-Host "[SKIP] Already in PATH: $p"
            continue
        }

        # Skip if directory does not exist on disk
        if (-not (Test-Path -LiteralPath $p)) {
            Write-Host "[SKIP] Path not found on disk: $p"
            continue
        }

        $added.Add($p)
    }

    if ($added.Count -gt 0) {
        $newUserPath = ($userPaths + $added) -join ';'
        [System.Environment]::SetEnvironmentVariable('PATH', $newUserPath, 'User')
        Write-Host "`nAdded $($added.Count) new path(s) to User PATH:"
        $added | ForEach-Object { Write-Host "  [+] $_" }
    } else {
        Write-Host "`nNothing to import — all paths were skipped."
    }
}
