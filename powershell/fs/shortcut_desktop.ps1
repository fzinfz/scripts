<#
.SYNOPSIS
    桌面快捷方式批量创建工具
.DESCRIPTION
    为 $ExeFiles 数组中列出的可执行文件，在桌面创建 .lnk 快捷方式。
    - 文件不存在则跳过并输出警告
    - 快捷方式名称取文件名（不含扩展名）
    - 图标使用可执行文件自身图标
.NOTES
    重构自: my\shortcut_desktop.ps1
    使用方式: 修改 $ExeFiles 数组后直接运行
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ─────────────────────────────────────────────
#  配置区 — 按需修改
# ─────────────────────────────────────────────

$ExeFiles = @(
    # 在此添加要创建快捷方式的可执行文件完整路径，示例：
    # 'C:\Program Files\Google\Chrome\Application\chrome.exe'
    # 'C:\Windows\System32\notepad.exe'
    # 'C:\Windows\System32\calc.exe'
)

# ─────────────────────────────────────────────
#  主流程
# ─────────────────────────────────────────────

$desktopPath  = [Environment]::GetFolderPath('Desktop')
$shell        = New-Object -ComObject WScript.Shell
$createdCount = 0
$skippedCount = 0

Write-Host "桌面路径: $desktopPath" -ForegroundColor Cyan

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
        Write-Warning "文件不存在: $exePath"
        $skippedCount++
    }
}

Write-Host ''
Write-Host "完成。创建: $createdCount  跳过: $skippedCount" -ForegroundColor Cyan
