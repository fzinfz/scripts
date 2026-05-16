<#
.SYNOPSIS
    批量修复 ps1 文件编码：为无 BOM 的 UTF-8 文件添加 BOM
.DESCRIPTION
    扫描指定目录（默认当前目录）下所有 .ps1 文件：
    - 已是 UTF-8 with BOM -> 跳过
    - 是无 BOM 的有效 UTF-8 -> 只加 BOM
    - 是 GBK/ANSI -> 转 UTF-8 with BOM
    PowerShell 5.x 在中文 Windows 上无 BOM 时会按 GBK 解读，导致中文乱码。
.PARAMETER Path
    要扫描的根目录路径，默认为脚本所在目录的父目录（即 scripts\powershell\）
.EXAMPLE
    .\fix_bom.ps1                    # 修复整个仓库
    .\fix_bom.ps1 -Path .\fs        # 只修复 fs/ 目录
#>

[CmdletBinding()]
param(
    [string]$Path
)

if (-not $Path) {
    $Path = Split-Path $PSScriptRoot -Parent
}

# 检测字节序列是否为有效 UTF-8
function Test-ValidUTF8 {
    param([string]$FilePath)
    try {
        $bytes = [System.IO.File]::ReadAllBytes($FilePath)
        $utf8 = New-Object System.Text.UTF8Encoding($false, $true)  # throwOnInvalidBytes
        $null = $utf8.GetString($bytes)
        return $true
    } catch {
        return $false
    }
}

$utf8bom = New-Object System.Text.UTF8Encoding($true)
$gbk    = [System.Text.Encoding]::GetEncoding(936)

$fixed  = 0
$skipped = 0

Get-ChildItem $Path -Recurse -Filter '*.ps1' |
    Where-Object { $_.FullName -notmatch '\.workbuddy' } |
    ForEach-Object {
        $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
        $hasBOM = ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)

        if ($hasBOM) {
            $skipped++
            return
        }

        $rel = $_.FullName.Replace($Path + '\', '')

        if (Test-ValidUTF8 $_.FullName) {
            # 有效 UTF-8，只加 BOM
            $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
            [System.IO.File]::WriteAllText($_.FullName, $content, $utf8bom)
            Write-Host "[UTF8+BOM] $rel" -ForegroundColor Cyan
        } else {
            # 按 GBK 读取，转 UTF-8 BOM
            $content = [System.IO.File]::ReadAllText($_.FullName, $gbk)
            [System.IO.File]::WriteAllText($_.FullName, $content, $utf8bom)
            Write-Host "[GBK->UTF8] $rel" -ForegroundColor Green
        }
        $fixed++
    }

Write-Host "`nDone. Fixed: $fixed | Skipped (already OK): $skipped" -ForegroundColor Yellow
