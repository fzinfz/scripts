# 重构详细变更记录

## 文件映射关系

| 原文件 | 新文件 | 变更说明 |
|--------|--------|----------|
| `Lib.ps1` | `Lib.ps1` | 全面重构，新增日志/执行/断言函数 |
| `EnvPath.lib.ps1` | `EnvPath.ps1` | 重命名去掉 `.lib`，参数加 `ValidateSet`，添加路径存在检查 |
| `Profile.ps1` | `Profile.ps1` | 清理，使用 `$PSScriptRoot` 替代硬编码路径 |
| `my.ps1` | `system\setup.ps1` | 拆分为独立 setup 脚本，加 `#Requires -RunAsAdministrator` |
| `check_env.ps1` | `system\check_env.ps1` | 迁移至 system 目录，使用新日志函数 |
| `host_info.ps1` | `system\host_info.ps1` | 迁移至 system 目录 |
| `nw\Lib.ps1` | *(合并)* | 内容仅一行，改为各脚本直接引入 `Lib.ps1` |
| `nw\Lib.Route.ps1` | `nw\Lib.Route.ps1` | 函数重命名，添加文档注释 |
| `nw\check.ps1` | `nw\check.ps1` | 提取 `Get-WanIp` / `Test-WanRoute` 函数，统一日志 |
| `nw\dns_check.ps1` | `nw\dns_check.ps1` | 使用 `Where-Object` 替代 `findstr`，添加标题 |
| `nw\firewall.ps1` | `nw\firewall.ps1` | 简化，添加标题输出 |
| `nw\ports.ps1` | `nw\ports.ps1` | 修复原代码多余反引号导致的换行 bug |
| `nw\reset_net.ps1` | `nw\reset_net.ps1` | 加 `#Requires -RunAsAdministrator`，添加警告提示 |
| `nw\route_switch.ps1` | `nw\route_switch.ps1` | 使用新路由库函数，添加参数断言 |
| `nw\trace_route.ps1` | `nw\trace_route.ps1` | 中文提示，无依赖 |
| `hyper-v\check.ps1` | `hyper-v\check.ps1` | 使用 `New-Object System.Net.WebClient` 规范下载，添加管理员要求 |
| `hyper-v\enable_hyper-v.ps1` | `hyper-v\enable_hyper-v.ps1` | 加 `#Requires -RunAsAdministrator`，使用 `Invoke-Step` |
| `hyper-v\get_cmds.ps1` | `hyper-v\get_cmds.ps1` | 使用日志函数，格式统一 |
| `hyper-v\pnp_dismount.ps1` | `hyper-v\pnp_dismount.ps1` | 提取 `Search-PnpByKeyword` 函数，使用 `-Confirm:$false` |
| `fs\files_usbMTP_ipad.ps1` | `fs\ipad_mtp.ps1` | 简化文件名，使用 `$Config` 统一配置，函数名 PascalCase 化 |
| `my\shortcut_desktop.ps1` | `my\shortcut_desktop.ps1` | 清理注释，使用 `Set-StrictMode` |
| `disk.ps1` | `disk.ps1` | 使用 `Get-PSDrive` 替代 `gdr`，使用 `Show-Volumes` |
| `top.ps1` | `top.ps1` | 使用 `Invoke-Steps`，修复 `Where-Object` 逻辑（原代码判断反了） |
| `openssh_client.ps1` | `openssh_client.ps1` | 统一日志输出，使用 `Invoke-Steps` |
| `openssh_server.ps1` | `openssh_server.ps1` | 加 `#Requires -RunAsAdministrator`，修复原代码 `ExpandPropert` typo，结构化各步骤 |
| `eject_removable.ps1` | `eject_removable.ps1` | 提取 `Invoke-EjectVolume` 函数（支持管道），使用 `Get-WmiObject` |
| `pnp.ps1` | `pnp.ps1` | 提取 `Show-PnpDevices` 函数，支持类别数组，格式统一 |

## Bug 修复

| 文件 | 原始问题 | 修复方式 |
|------|----------|----------|
| `nw\ports.ps1` | 反引号后换行导致 `Select-Object` 丢失管道 | 移除多余反引号，整理管道格式 |
| `top.ps1` | `Where-Object { ! $_.Count -lt 1 }` 逻辑错误（始终为真） | 改为 `Where-Object { $_.Count -ge 1 }` |
| `openssh_server.ps1` | `Select-Object -ExpandPropert Name` 拼写错误 | 改为 `Select-Object -ExpandProperty Name` |
| `eject_removable.ps1` | `filter eject_volume()` 函数中 eject 操作被注释但未说明 | 改为普通函数，在注释中明确说明已注释的意图 |

## 规范改进汇总

### 之前（原始代码）

```powershell
function tip {
    Write-Host -ForegroundColor Yellow `n[TIP] $args[0]
}

function run {
    param ([Parameter(Mandatory=$true)] [string] $commands)
    "$commands".Split([Environment]::NewLine) | ? {$_.trim() -ne "" } | % {
        Write-Host -ForegroundColor Green "`n[RUN] $_"
        Invoke-Expression $_
    }
}
```

### 之后（重构代码）

```powershell
function Write-Tip {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    Write-Host -ForegroundColor Yellow "`n[TIP] $Message"
}

function Invoke-Steps {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Commands
    )
    $Commands.Split([Environment]::NewLine) |
        Where-Object { $_.Trim() -ne '' } |
        ForEach-Object { Invoke-Step $_ }
}
```

### 改进对照表

| 改进项 | 原始 | 重构后 |
|--------|------|--------|
| 严格模式 | 无 | `Set-StrictMode -Version Latest` |
| 错误处理 | 无 | `$ErrorActionPreference = 'Stop'` |
| 管理员检查 | 手动 Security.Principal 检查 | `#Requires -RunAsAdministrator` |
| 函数文档 | 无或极少 | 100% 使用 `.SYNOPSIS/.PARAMETER` |
| 参数类型 | 部分有 | 全部声明类型和 `Mandatory` |
| 别名使用 | `?`, `%`, `ft`, `gdr`, `gwmi` | 使用完整 cmdlet 名 |
| 引用路径 | 硬编码 `D:\GitHub\scripts\powershell` | `$PSScriptRoot` 相对引用 |
| 颜色输出 | `tip`/`run` 不统一 | `Write-Step`/`Write-Tip`/`Write-Info`/`Write-Warn` |
| 空行过滤 | `? {$_.trim() -ne ""}` | `Where-Object { $_.Trim() -ne '' }` |
| 字符串 | 混用 `""` `''` | 空字符串用 `''`，插值用 `""` |
