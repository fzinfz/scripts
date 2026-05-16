<#
.SYNOPSIS
    VS Code Remote-SSH 密钥文件权限检查与修复
.DESCRIPTION
    1. 读取 VS Code Remote-SSH 扩展的 SSH 配置文件
    2. 提取所有 IdentityFile 路径并去重
    3. 检查每个密钥文件的权限
    4. 修复不符合要求的权限（仅当前用户可访问）
.NOTES
    Remote-SSH 扩展默认使用 ~/.ssh/config，也可通过 VS Code 设置 remote.SSH.configFile 指定其他路径
    修复权限时会将继承权限移除，仅保留当前用户 (NT AUTHORITY\SYSTEM + 当前用户) 的访问权限
    参考: https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement
#>

. $PSScriptRoot\..\Lib.ps1

# ─── 1. 定位 SSH 配置文件 ─────────────────────

$sshConfigPaths = @()

# 1.1 VS Code Remote-SSH 设置中的自定义配置路径
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
                    Write-Info "VS Code 设置中的 SSH 配置: $resolved"
                }
            }
        }
        catch {
            Write-Warn "读取 VS Code 设置失败: $settingsPath"
        }
    }
}

# 1.2 默认 SSH 配置文件
$defaultSshConfig = "$env:USERPROFILE\.ssh\config"
if (Test-Path $defaultSshConfig) {
    $sshConfigPaths += $defaultSshConfig
    Write-Info "默认 SSH 配置: $defaultSshConfig"
}

# 去重配置路径
$sshConfigPaths = @($sshConfigPaths | Select-Object -Unique)

if (@($sshConfigPaths).Count -eq 0) {
    Write-Warn "未找到任何 SSH 配置文件"
    return
}

# ─── 2. 解析 IdentityFile ─────────────────────

$identityFiles = @()

foreach ($configPath in $sshConfigPaths) {
    Write-Step "解析: $configPath"

    $lines = Get-Content $configPath -ErrorAction SilentlyContinue
    if ($null -eq $lines) { continue }

    foreach ($line in $lines) {
        $trimmed = $line.Trim()

        # 跳过空行和注释
        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('#')) {
            continue
        }

        # 匹配 IdentityFile 指令（忽略大小写）
        if ($trimmed -imatch '^IdentityFile\s+(.+)$') {
            $filePath = $matches[1].Trim().Trim('"').Trim("'")

            # 展开 ~ 为用户目录
            if ($filePath.StartsWith('~/') -or $filePath.StartsWith('~\')) {
                $filePath = $filePath.Replace('~', $env:USERPROFILE)
            }

            # 解析相对路径（相对于 .ssh 目录）
            if (-not [System.IO.Path]::IsPathRooted($filePath)) {
                $filePath = Join-Path "$env:USERPROFILE\.ssh" $filePath
            }

            # 展开环境变量
            $filePath = [Environment]::ExpandEnvironmentVariables($filePath)

            # 规范化路径
            try {
                $filePath = (Resolve-Path $filePath -ErrorAction SilentlyContinue).Path
            }
            catch {
                # 文件不存在，保留原路径用于后续提示
            }

            $identityFiles += $filePath
        }
    }
}

# 去重
$uniqueIdentityFiles = $identityFiles | Select-Object -Unique

if (@($uniqueIdentityFiles).Count -eq 0) {
    Write-Warn "未在配置文件中找到 IdentityFile 条目"
    return
}

Write-Step "发现 $(@($uniqueIdentityFiles).Count) 个唯一 IdentityFile"

# ─── 3. 检查并修复权限 ────────────────────────

$currentUser = "$env:USERDOMAIN\$env:USERNAME"
$systemUser = 'NT AUTHORITY\SYSTEM'

foreach ($keyPath in $uniqueIdentityFiles) {
    Write-Host "`n----------------------------------------"
    Write-Host "密钥文件: $keyPath"

    if (-not (Test-Path $keyPath)) {
        Write-Warn "文件不存在: $keyPath"
        continue
    }

    # 获取当前 ACL
    $acl = Get-Acl $keyPath
    $needsFix = $false

    Write-Host "当前权限:"
    foreach ($ace in $acl.Access) {
        $identity = $ace.IdentityReference.Value
        $rights = $ace.FileSystemRights
        $isInherited = $ace.IsInherited
        $inheritStr = if ($isInherited) { ' [继承]' } else { '' }
        Write-Host "  - $identity : $rights$inheritStr"

        # 检查是否需要修复
        # 只允许当前用户和 SYSTEM 访问
        $allowed = @($currentUser, $systemUser, 'BUILTIN\Administrators')
        if ($allowed -notcontains $identity -and $identity -ne 'NT AUTHORITY\SYSTEM') {
            $needsFix = $true
        }

        # 如果 Everyone 或 Users 有权限，也需要修复
        if ($identity -match 'Everyone|Users|Authenticated Users') {
            $needsFix = $true
        }
    }

    if ($needsFix) {
        Write-Warn "权限过于宽松，需要修复"

        # 创建新 ACL
        $newAcl = New-Object System.Security.AccessControl.FileSecurity

        # 添加当前用户权限
        $userRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $currentUser,
            [System.Security.AccessControl.FileSystemRights]::FullControl,
            [System.Security.AccessControl.InheritanceFlags]::None,
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $newAcl.SetAccessRule($userRule)

        # 添加 SYSTEM 权限（某些场景需要）
        $systemRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $systemUser,
            [System.Security.AccessControl.FileSystemRights]::FullControl,
            [System.Security.AccessControl.InheritanceFlags]::None,
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $newAcl.SetAccessRule($systemRule)

        # 应用 ACL
        try {
            Set-Acl $keyPath $newAcl
            Write-Host -ForegroundColor Green "权限已修复: $keyPath"
        }
        catch {
            Write-Warn "权限修复失败: $_"
        }
    }
    else {
        Write-Host -ForegroundColor Green "权限正常"
    }
}

Write-Step '权限检查完成'
