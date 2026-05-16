<#
.SYNOPSIS
    VS Code Remote-SSH Key File Permission Check & Fix
.DESCRIPTION
    1. Read VS Code Remote-SSH extension's SSH config file
    2. Extract all IdentityFile paths and deduplicate
    3. Check permissions for each key file
    4. Fix non-compliant permissions (allow only current user access)
.NOTES
    Remote-SSH extension defaults to ~/.ssh/config, or use the path specified in VS Code setting remote.SSH.configFile
    When fixing permissions, inherited permissions are removed; only the current user + NT AUTHORITY\SYSTEM retain access
    Reference: https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement
#>

. $PSScriptRoot\..\Lib.ps1

# ── 1. Locate SSH config file ────────────────────

$sshConfigPaths = @()

# 1.1 Custom config path from VS Code Remote-SSH settings
$vscodeSettingsPaths = @(
    "$env:APPDATA\Code\User\settings.json",
    "$env:APPDATA\Code - Insiders\User\settings.json",
    "$env:APPDATA\Code - OSS\User\settings.json",
    "$env:USERPROFILE\.vscode\settings.json"
)

foreach ($settingsPath in $vscodeSettingsPaths) {
    if (Test-Path $settingsPath) {
        try {
            $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
            $customConfig = $settings.'remote.SSH.configFile'
            if (-not [string]::IsNullOrWhiteSpace($customConfig)) {
                $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($customConfig)
                if (Test-Path $resolved) {
                    $sshConfigPaths += $resolved
                    Write-Info "SSH config from VS Code settings: $resolved"
                }
            }
        }
        catch {
            Write-Warn "Failed to read VS Code settings: $settingsPath"
        }
    }
}

# 1.2 Default SSH config file
$defaultSshConfig = "$env:USERPROFILE\.ssh\config"
if (Test-Path $defaultSshConfig) {
    $sshConfigPaths += $defaultSshConfig
    Write-Info "Default SSH config: $defaultSshConfig"
}

# Deduplicate config paths
$sshConfigPaths = @($sshConfigPaths | Select-Object -Unique)

if (@($sshConfigPaths).Count -eq 0) {
    Write-Warn "No SSH config file found"
    return
}

# ── 2. Parse IdentityFile ────────────────────

$identityFiles = @()

foreach ($configPath in $sshConfigPaths) {
    Write-Step "Parsing: $configPath"

    $lines = Get-Content $configPath -ErrorAction SilentlyContinue
    if ($null -eq $lines) { continue }

    foreach ($line in $lines) {
        $trimmed = $line.Trim()

        # Skip empty lines and comments
        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('#')) {
            continue
        }

        # Match IdentityFile directive (case-insensitive)
        if ($trimmed -imatch '^IdentityFile\s+(.+)$') {
            $filePath = $matches[1].Trim().Trim('"').Trim("'")

            # Expand ~ to user home
            if ($filePath.StartsWith('~/') -or $filePath.StartsWith('~')) {
                $filePath = $filePath.Replace('~', $env:USERPROFILE)
            }

            # Resolve relative path (relative to .ssh dir)
            if (-not [System.IO.Path]::IsPathRooted($filePath)) {
                $filePath = Join-Path "$env:USERPROFILE\.ssh" $filePath
            }

            # Expand environment variables
            $filePath = [Environment]::ExpandEnvironmentVariables($filePath)

            # Normalize path
            try {
                $filePath = (Resolve-Path $filePath -ErrorAction SilentlyContinue).Path
            }
            catch {
                # File does not exist, keep original path for later warning
            }

            $identityFiles += $filePath
        }
    }
}

# Deduplicate
$uniqueIdentityFiles = $identityFiles | Select-Object -Unique

if (@($uniqueIdentityFiles).Count -eq 0) {
    Write-Warn "No IdentityFile entries found in config files"
    return
}

Write-Step "Found $(@($uniqueIdentityFiles).Count) unique IdentityFile(s)"

# ── 3. Check and fix permissions ────────────────────

$currentUser = "$env:USERDOMAIN\$env:USERNAME"
$systemUser = 'NT AUTHORITY\SYSTEM'

foreach ($keyPath in $uniqueIdentityFiles) {
    Write-Host "`n----------------------------------------"
    Write-Host "Key file: $keyPath"

    if (-not (Test-Path $keyPath)) {
        Write-Warn "File not found: $keyPath"
        continue
    }

    # Get current ACL
    $acl = Get-Acl $keyPath
    $needsFix = $false

    Write-Host "Current permissions:"
    foreach ($ace in $acl.Access) {
        $identity = $ace.IdentityReference.Value
        $rights = $ace.FileSystemRights
        $isInherited = $ace.IsInherited
        $inheritStr = if ($isInherited) { ' [Inherited]' } else { '' }
        Write-Host "  - $identity : $rights$inheritStr"

        # Check if fix is needed
        # Only allow current user and SYSTEM
        $allowed = @($currentUser, $systemUser, 'BUILTIN\Administrators')
        if ($allowed -notcontains $identity -and $identity -ne 'NT AUTHORITY\SYSTEM') {
            $needsFix = $true
        }

        # If Everyone or Users have permissions, also needs fix
        if ($identity -match 'Everyone|Users|Authenticated Users') {
            $needsFix = $true
        }
    }

    if ($needsFix) {
        Write-Warn "Permissions too loose, need to fix"

        # Create new ACL
        $newAcl = New-Object System.Security.AccessControl.FileSecurity

        # Add current user permission
        $userRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $currentUser,
            [System.Security.AccessControl.FileSystemRights]::FullControl,
            [System.Security.AccessControl.InheritanceFlags]::None,
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $newAcl.SetAccessRule($userRule)

        # Add SYSTEM permission (needed in some scenarios)
        $systemRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $systemUser,
            [System.Security.AccessControl.FileSystemRights]::FullControl,
            [System.Security.AccessControl.InheritanceFlags]::None,
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $newAcl.SetAccessRule($systemRule)

        # Apply ACL
        try {
            Set-Acl $keyPath $newAcl
            Write-Host -ForegroundColor Green "Permissions fixed: $keyPath"
        }
        catch {
            Write-Warn "Permission fix failed: $_"
        }
    }
    else {
        Write-Host -ForegroundColor Green "Permissions OK"
    }
}

Write-Step 'Permission check complete'
