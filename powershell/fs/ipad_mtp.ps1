<#
.SYNOPSIS
    # seems not working well on Windows, switched to linux ifuse
    iPad MTP 文件管理工具（复制 / 删除模式） 
.DESCRIPTION
    通过 Windows Shell.Application COM 对象访问 USB 连接的 iPad（MTP/PTP），
    提供两种操作模式：
    1. 复制 iPad 文件到本地（递归，已存在则跳过）
    2. 删除 iPad 上已同步到本地的文件（跳过 MOV/MP4）

    限制说明：
    - Robocopy 仅支持文件系统路径，无法访问 MTP 设备。
    - 本脚本改用 Shell.Application CopyHere 方法实现传输。
    - 大文件（视频）可能复制不完整，已自动跳过 MOV/MP4 扩展名。
    - 删除操作无法静默确认，需要手动处理弹窗（已知限制）。
.NOTES
    重构自: fs\files_usbMTP_ipad.ps1
    前提：iTunes 已安装（依赖 Apple MTP 驱动）
          iPad 已解锁并信任此电脑
    建议以管理员身份运行（写入 D:\ 需要权限）
#>

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ─────────────────────────────────────────────
#  配置区 — 按需修改
# ─────────────────────────────────────────────
$Config = @{
    DeviceName      = 'Apple iPad'            # 在「此电脑」中显示的设备名
    InternalPath    = 'Internal Storage'      # iOS 内部存储名称
    LocalTargetRoot = 'D:\_images\iPad' # 本地同步根目录
}

# ─────────────────────────────────────────────
#  辅助函数
# ─────────────────────────────────────────────

<#
.SYNOPSIS
    通过 Shell Namespace 获取 MTP 设备的内部存储文件夹对象
.PARAMETER DevName
    设备名称（与「此电脑」中显示一致）
.PARAMETER SubPath
    子路径名（通常为 Internal Storage）
.OUTPUTS
    Shell Folder COM 对象
#>
function Get-MtpDeviceFolder {
    param(
        [Parameter(Mandatory = $true)] [string]$DevName,
        [Parameter(Mandatory = $true)] [string]$SubPath
    )

    Write-Host '初始化 Shell Application...' -ForegroundColor Cyan
    $shell  = New-Object -ComObject Shell.Application
    $thisPC = $shell.NameSpace('::{20D04FE0-3AEA-1069-A2D8-08002B30309D}')

    if (-not $thisPC) { throw "无法访问「此电脑」命名空间" }

    $deviceItem = $thisPC.Items() |
        Where-Object { $_.Name -eq $DevName } |
        Select-Object -First 1

    if (-not $deviceItem) {
        throw "未找到设备「$DevName」，请确认 iPad 已连接、解锁并已选择信任此电脑。"
    }

    $storageItem = $deviceItem.GetFolder.Items() |
        Where-Object { $_.Name -eq $SubPath } |
        Select-Object -First 1

    if (-not $storageItem) {
        throw "在设备「$DevName」中未找到子路径「$SubPath」"
    }

    return $storageItem.GetFolder
}

<#
.SYNOPSIS
    规范化 MTP 文件项的文件名（自动补充扩展名）
.PARAMETER Item
    MTP Shell FolderItem COM 对象
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
    递归将 MTP 文件夹内容复制到本地目录（跳过已存在文件）
.PARAMETER MtpFolder
    源 MTP Shell Folder COM 对象
.PARAMETER LocalDir
    本地目标目录路径
#>
function Copy-MtpContent {
    param(
        [Parameter(Mandatory = $true)] $MtpFolder,
        [Parameter(Mandatory = $true)] [string]$LocalDir
    )

    if (-not (Test-Path -Path $LocalDir)) {
        New-Item -Path $LocalDir -ItemType Directory -Force | Out-Null
        Write-Host "创建目录: $LocalDir" -ForegroundColor DarkGray
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
                Write-Host "跳过（已存在）: $localFile" -ForegroundColor Yellow
            }
            else {
                Write-Host "复制: $localFile" -ForegroundColor Green
                try {
                    # Flags=8: 目标已存在时自动重命名
                    $destFolder.CopyHere($item, 8)
                    Start-Sleep -Milliseconds 200   # 等待 COM 异步完成
                }
                catch {
                    Write-Error "复制失败 $fileName : $_"
                }
            }
        }
    }
}

<#
.SYNOPSIS
    递归删除 iPad 上已同步到本地的文件（跳过 MOV/MP4）
.PARAMETER MtpFolder
    源 MTP Shell Folder COM 对象
.PARAMETER LocalDir
    本地对应目录路径
#>
function Remove-SyncedMtpFiles {
    param(
        [Parameter(Mandatory = $true)] $MtpFolder,
        [Parameter(Mandatory = $true)] [string]$LocalDir
    )

    if (-not (Test-Path -Path $LocalDir)) {
        Write-Warning "本地目录不存在，跳过: $LocalDir"
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
                Write-Host "跳过（视频）: $fileName" -ForegroundColor Yellow
                continue
            }

            if (Test-Path -Path $localFile) {
                Write-Host "删除 iPad 文件: $fileName" -ForegroundColor Magenta
                try {
                    if ($item | Get-Member -Name 'Remove' -ErrorAction SilentlyContinue) {
                        $item.Remove(0)
                    }
                    else {
                        $item.InvokeVerb('delete')
                        Start-Sleep -Milliseconds 400
                        # 注意：删除确认弹窗需手动操作（已知限制）
                    }
                }
                catch {
                    Write-Error "删除失败 $fileName : $_"
                }
            }
            else {
                Write-Host "保留（本地无此文件）: $fileName" -ForegroundColor DarkGray
            }
        }
    }
}

# ─────────────────────────────────────────────
#  主流程
# ─────────────────────────────────────────────

Clear-Host
Write-Host '===========================================' -ForegroundColor Cyan
Write-Host '       iPad MTP 文件管理工具'              -ForegroundColor Cyan
Write-Host '===========================================' -ForegroundColor Cyan
Write-Host "设备: $($Config.DeviceName)"
Write-Host "来源: $($Config.InternalPath)"
Write-Host "目标: $($Config.LocalTargetRoot)"
Write-Host ''
Write-Host '1. 复制所有文件（本地已存在则跳过）'
Write-Host '2. 删除 iPad 文件（本地已同步则删除）'
Write-Host 'Q. 退出'
Write-Host ''

$choice = Read-Host '选择操作'

if ($choice -in 'Q', 'q') { exit 0 }

try {
    Write-Host "`n连接 iPad..." -ForegroundColor Cyan
    $rootFolder = Get-MtpDeviceFolder -DevName $Config.DeviceName -SubPath $Config.InternalPath
    Write-Host '连接成功。' -ForegroundColor Green

    if ($choice -eq '1') {
        Write-Host '开始复制...' -ForegroundColor Cyan
        Copy-MtpContent -MtpFolder $rootFolder -LocalDir $Config.LocalTargetRoot
        Write-Host "`n复制完成。" -ForegroundColor Green
    }
    elseif ($choice -eq '2') {
        Write-Warning "此操作将永久删除 iPad 上在「$($Config.LocalTargetRoot)」存在的文件！"
        $confirm = Read-Host "输入 YES 确认"
        if ($confirm -eq 'YES') {
            Remove-SyncedMtpFiles -MtpFolder $rootFolder -LocalDir $Config.LocalTargetRoot
            Write-Host "`n删除操作完成。" -ForegroundColor Green
        }
        else {
            Write-Host '已取消。' -ForegroundColor Yellow
        }
    }
    else {
        Write-Host '无效选项。' -ForegroundColor Red
    }
}
catch {
    Write-Error "发生错误: $($_.Exception.Message)"
}

Write-Host "`n按任意键退出..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
