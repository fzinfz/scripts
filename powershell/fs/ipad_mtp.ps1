<#
.SYNOPSIS
    iPad MTP File Management Tool (Copy / Delete Mode)
.DESCRIPTION
    Access USB-connected iPad (MTP/PTP) via Windows Shell.Application COM object.
    Provides two operation modes:
    1. Copy iPad files to local (recursive, skip if already exists)
    2. Delete files on iPad that are already synced locally (skip MOV/MP4)
.NOTES
    Refactored from: fs\files_usbMTP_ipad.ps1
    Prerequisite: iTunes installed (depends on Apple MTP driver)
                 iPad unlocked and trusted this computer
    Recommended to run as Administrator (writing to D:\ requires permission)
.LIMITATIONS
    - Robocopy only supports filesystem paths, cannot access MTP devices.
    - This script uses Shell.Application CopyHere method for transfer.
    - Large files (videos) may copy incompletely; MOV/MP4 extensions are auto-skipped.
    - Delete operation cannot be silent; manual confirmation popup is required (known limitation).
#>

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ────────────────────────────────────────────
#  Config — modify as needed
# ────────────────────────────────────────────

$Config = @{
    DeviceName      = 'Apple iPad'            # Device name as shown in "This PC"
    InternalPath    = 'Internal Storage'      # iOS internal storage name
    LocalTargetRoot = 'D:\_images\iPad'     # Local sync root directory
}

# ────────────────────────────────────────────
#  Helper Functions
# ────────────────────────────────────────────

<#
.SYNOPSIS
    Get MTP device internal storage folder object via Shell Namespace
.PARAMETER DevName
    Device name (must match what is shown in "This PC")
.PARAMETER SubPath
    Subfolder name (usually Internal Storage)
.OUTPUTS
    Shell Folder COM object
#>
function Get-MtpDeviceFolder {
    param(
        [Parameter(Mandatory = $true)] [string]$DevName,
        [Parameter(Mandatory = $true)] [string]$SubPath
    )

    Write-Host 'Initializing Shell.Application...' -ForegroundColor Cyan
    $shell  = New-Object -ComObject Shell.Application
    $thisPC = $shell.NameSpace('::{20D04FE0-3AEA-1069-A2D8-08002B30309D}')

    if (-not $thisPC) { throw "Cannot access 'This PC' namespace" }

    $deviceItem = $thisPC.Items() |
        Where-Object { $_.Name -eq $DevName } |
        Select-Object -First 1

    if (-not $deviceItem) {
        throw "Device '$DevName' not found. Check iPad is connected, unlocked, and trusted this computer."
    }

    $storageItem = $deviceItem.GetFolder.Items() |
        Where-Object { $_.Name -eq $SubPath } |
        Select-Object -First 1

    if (-not $storageItem) {
        throw "Subpath '$SubPath' not found on device '$DevName'"
    }

    return $storageItem.GetFolder
}

<#
.SYNOPSIS
    Normalize MTP file item name (auto-append extension)
.PARAMETER Item
    MTP Shell FolderItem COM object
#>
function Get-MtpFileName {
    param([Parameter(Mandatory = $true)] $Item)

    $name = $Item.Name
    $type = $Item.Type
    if ($type -match '(\w+) File$') {
        $ext = '.' + $Matches[1]
        if ($name -notmatch [regex]::Escape($ext)) {
            $name += $ext
        }
    }
    return $name
}

<#
.SYNOPSIS
    Recursively copy MTP folder contents to local directory (skip existing files)
.PARAMETER MtpFolder
    Source MTP Shell Folder COM object
.PARAMETER LocalDir
    Local target directory path
#>
function Copy-MtpContent {
    param(
        [Parameter(Mandatory = $true)] $MtpFolder,
        [Parameter(Mandatory = $true)] [string]$LocalDir
    )

    if (-not (Test-Path -Path $LocalDir)) {
        New-Item -Path $LocalDir -ItemType Directory -Force | Out-Null
        Write-Host "Created directory: $LocalDir" -ForegroundColor DarkGray
    }

    $shell      = New-Object -ComObject Shell.Application
    $destFolder = $shell.NameSpace($LocalDir)

    foreach ($item in $MtpFolder.Items()) {
        if ($item.IsFolder) {
            Copy-MtpContent -MtpFolder $item.GetFolder -LocalDir (Join-Path $LocalDir $item.Name)
        }
        else {
            $fileName     = Get-MtpFileName -Item $item
            $localFile    = Join-Path $LocalDir $fileName

            if ((Test-Path -Path $localFile) -or ($fileName -match '\.(AAE)$')) {
                Write-Host "Skipped (already exists): $localFile" -ForegroundColor Yellow
            }
            else {
                Write-Host "Copying: $localFile" -ForegroundColor Green
                try {
                    # Flags=8: auto-rename if target exists
                    $destFolder.CopyHere($item, 8)
                    Start-Sleep -Milliseconds 200   # Wait for COM async completion
                }
                catch {
                    Write-Error "Copy failed $fileName : $_"
                }
            }
        }
    }
}

<#
.SYNOPSIS
    Recursively delete files on iPad that are already synced locally (skip MOV/MP4)
.PARAMETER MtpFolder
    Source MTP Shell Folder COM object
.PARAMETER LocalDir
    Corresponding local directory path
#>
function Remove-SyncedMtpFiles {
    param(
        [Parameter(Mandatory = $true)] $MtpFolder,
        [Parameter(Mandatory = $true)] [string]$LocalDir
    )

    if (-not (Test-Path -Path $LocalDir)) {
        Write-Warning "Local directory not found, skipping: $LocalDir"
        return
    }

    foreach ($item in $MtpFolder.Items()) {
        if ($item.IsFolder) {
            Remove-SyncedMtpFiles -MtpFolder $item.GetFolder -LocalDir (Join-Path $LocalDir $item.Name)
        }
        else {
            $fileName  = Get-MtpFileName -Item $item
            $localFile = Join-Path $LocalDir $fileName

            if ($item.Type -match 'MOV|MP4') {
                Write-Host "Skipped (video): $fileName" -ForegroundColor Yellow
                continue
            }

            if (Test-Path -Path $localFile) {
                Write-Host "Deleting iPad file: $fileName" -ForegroundColor Magenta
                try {
                    if ($item | Get-Member -Name 'Remove' -ErrorAction SilentlyContinue) {
                        $item.Remove(0)
                    }
                    else {
                        $item.InvokeVerb('delete')
                        Start-Sleep -Milliseconds 400
                        # Note: delete confirmation popup requires manual operation (known limitation)
                    }
                }
                catch {
                    Write-Error "Delete failed $fileName : $_"
                }
            }
            else {
                Write-Host "Kept (not found locally): $fileName" -ForegroundColor DarkGray
            }
        }
    }
}

# ────────────────────────────────────────────
#  Main Flow
# ────────────────────────────────────────────

Clear-Host
Write-Host '===========================================' -ForegroundColor Cyan
Write-Host '       iPad MTP File Management Tool'       -ForegroundColor Cyan
Write-Host '===========================================' -ForegroundColor Cyan
Write-Host "Device  : $($Config.DeviceName)"
Write-Host "Source  : $($Config.InternalPath)"
Write-Host "Target  : $($Config.LocalTargetRoot)"
Write-Host ''
Write-Host '1. Copy all files (skip if already exists)'
Write-Host '2. Delete iPad files (delete if synced locally)'
Write-Host 'Q. Quit'
Write-Host ''

$choice = Read-Host 'Select operation'

if ($choice -in 'Q', 'q') { exit 0 }

try {
    Write-Host "`nConnecting to iPad..." -ForegroundColor Cyan
    $rootFolder = Get-MtpDeviceFolder -DevName $Config.DeviceName -SubPath $Config.InternalPath
    Write-Host 'Connected.' -ForegroundColor Green

    if ($choice -eq '1') {
        Write-Host 'Starting copy...' -ForegroundColor Cyan
        Copy-MtpContent -MtpFolder $rootFolder -LocalDir $Config.LocalTargetRoot
        Write-Host "`nCopy complete." -ForegroundColor Green
    }
    elseif ($choice -eq '2') {
        Write-Warning "This operation will permanently delete files on iPad that exist in '$($Config.LocalTargetRoot)'!"
        $confirm = Read-Host "Type YES to confirm"
        if ($confirm -eq 'YES') {
            Remove-SyncedMtpFiles -MtpFolder $rootFolder -LocalDir $Config.LocalTargetRoot
            Write-Host "`nDelete operation complete." -ForegroundColor Green
        }
        else {
            Write-Host 'Cancelled.' -ForegroundColor Yellow
        }
    }
    else {
        Write-Host 'Invalid option.' -ForegroundColor Red
    }
}
catch {
    Write-Error "Error occurred: $($_.Exception.Message)"
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
