# cleanup_duplicates.ps1
# Finds files in OLD_DIR that have a matching name+size in NEW_DIR,
# then asks the user to confirm before deleting them from OLD_DIR.

$OLD_DIR = "D:\chat\WeChat Files 2023"
$NEW_DIR = "D:\ProgramData\xwechat_files"

# ── Sanity checks ────────────────────────────────────────────────────────────
if (-not (Test-Path $OLD_DIR)) {
    Write-Error "OLD_DIR not found: $OLD_DIR"
    exit 1
}
if (-not (Test-Path $NEW_DIR)) {
    Write-Error "NEW_DIR not found: $NEW_DIR"
    exit 1
}

Write-Host "`nScanning OLD_DIR : $OLD_DIR" -ForegroundColor Cyan
Write-Host "Comparing against: $NEW_DIR`n" -ForegroundColor Cyan

# ── Build a lookup table for NEW_DIR: "name|size" -> full path ───────────────
$newIndex = @{}
Get-ChildItem -Path $NEW_DIR -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    $key = "$($_.Name)|$($_.Length)"
    if (-not $newIndex.ContainsKey($key)) {
        $newIndex[$key] = $_.FullName
    }
}

# ── Find duplicates in OLD_DIR ────────────────────────────────────────────────
$duplicates = @()
Get-ChildItem -Path $OLD_DIR -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    $key = "$($_.Name)|$($_.Length)"
    if ($newIndex.ContainsKey($key)) {
        $duplicates += [PSCustomObject]@{
            OldPath  = $_.FullName
            NewPath  = $newIndex[$key]
            Name     = $_.Name
            SizeKB   = [math]::Round($_.Length / 1KB, 1)
        }
    }
}

if ($duplicates.Count -eq 0) {
    Write-Host "No duplicate files found. Nothing to delete." -ForegroundColor Green
    exit 0
}

# ── Display results ───────────────────────────────────────────────────────────
Write-Host ("Found {0} duplicate file(s) (same name + size in both dirs):`n" -f $duplicates.Count) -ForegroundColor Yellow

$duplicates | Format-Table -AutoSize -Property @(
    @{Label="File Name";  Expression={$_.Name}},
    @{Label="Size (KB)";  Expression={$_.SizeKB}},
    @{Label="OLD path";   Expression={$_.OldPath}},
    @{Label="NEW path";   Expression={$_.NewPath}}
)

# ── Confirmation ──────────────────────────────────────────────────────────────
Write-Host "⚠️  WARNING: The following files will be PERMANENTLY DELETED from OLD_DIR." -ForegroundColor Red
Write-Host "    This action cannot be undone!" -ForegroundColor Red
Write-Host ""
$answer = Read-Host "Type YES (all caps) to confirm deletion, or anything else to abort"

if ($answer -ne "YES") {
    Write-Host "`nAborted. No files were deleted." -ForegroundColor Green
    exit 0
}

# ── Delete ────────────────────────────────────────────────────────────────────
$deleted  = 0
$failed   = 0

foreach ($dup in $duplicates) {
    try {
        Remove-Item -LiteralPath $dup.OldPath -Force -ErrorAction Stop
        Write-Host "  DELETED: $($dup.OldPath)" -ForegroundColor Green
        $deleted++
    } catch {
        Write-Host "  FAILED : $($dup.OldPath) -- $_" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`nDone. Deleted: $deleted  |  Failed: $failed" -ForegroundColor Cyan
