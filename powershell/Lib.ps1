<#
.SYNOPSIS
    PowerShell 公共工具库 - 2026 版
.DESCRIPTION
    提供统一的日志输出、命令执行、交互辅助等核心功能。
    所有功能脚本通过 . .\Lib.ps1 或 . $PSScriptRoot\..\Lib.ps1 引入。
.NOTES
    规范：
    - 函数命名使用 动词-名词 (Verb-Noun) Pascal 式，或 snake_case 辅助函数
    - 日志函数：Write-Info / Write-Tip / Write-Step / Write-Warn
    - 命令执行：Invoke-Step（单条）/ Invoke-Steps（多行文本批量执行）
    - 参数校验：Assert-Param
    - 颜色约定：Green=成功/执行, Yellow=提示/警告, Red=错误, Cyan=标题/信息
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ─────────────────────────────────────────────
#  版本信息
# ─────────────────────────────────────────────

$PSVersionTable | Format-Table

# ─────────────────────────────────────────────
#  正则常量
# ─────────────────────────────────────────────

$Script:pattern_ip = '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'

# ─────────────────────────────────────────────
#  日志输出
# ─────────────────────────────────────────────

<#
.SYNOPSIS
    输出绿色步骤标题
.PARAMETER Message
    步骤说明文字
#>
function Write-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    Write-Host -ForegroundColor Green "`n=== $Message ==="
}

<#
.SYNOPSIS
    输出黄色提示信息
.PARAMETER Message
    提示文字
#>
function Write-Tip {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    Write-Host -ForegroundColor Yellow "`n[TIP] $Message"
}

<#
.SYNOPSIS
    输出蓝色普通信息
.PARAMETER Message
    信息文字
#>
function Write-Info {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    Write-Information "`n[INFO] $Message" -InformationAction Continue
}

<#
.SYNOPSIS
    输出红色警告/错误
.PARAMETER Message
    警告文字
#>
function Write-Warn {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    Write-Host -ForegroundColor Red "`n[WARN] $Message"
}

# ─────────────────────────────────────────────
#  命令执行
# ─────────────────────────────────────────────

<#
.SYNOPSIS
    执行单条命令并打印命令本身（绿色）
.PARAMETER Command
    要执行的命令字符串
#>
function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    Write-Host -ForegroundColor Green "`n[RUN] $Command"
    Invoke-Expression $Command
}

<#
.SYNOPSIS
    批量执行多行命令（每行一条，忽略空行）
.PARAMETER Commands
    多行命令字符串，可用 here-string 传入
#>
function Invoke-Steps {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Commands
    )
    $Commands.Split([Environment]::NewLine) |
        Where-Object { $_.Trim() -ne '' } |
        ForEach-Object { Invoke-Step $_ }
}

<#
.SYNOPSIS
    提示确认后再执行命令
.PARAMETER Command
    要执行的命令字符串
#>
function Invoke-StepWithConfirm {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    Read-Host -Prompt "`nPress Enter to run: $Command"
    Invoke-Step $Command
}

# ─────────────────────────────────────────────
#  参数校验
# ─────────────────────────────────────────────

<#
.SYNOPSIS
    断言参数不为空，否则抛出异常
.PARAMETER Value
    要检查的值
.PARAMETER Name
    参数名称（用于错误提示）
#>
function Assert-Param {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Value,

        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "必填参数 '$Name' 不能为空"
    }
}

# ─────────────────────────────────────────────
#  管道过滤器
# ─────────────────────────────────────────────

<#
.SYNOPSIS
    过滤器：将多行字符串按行拆分，去除空行
#>
filter Split-Lines {
    $_.Split([Environment]::NewLine) | Where-Object { $_.Trim() -ne '' }
}

# ─────────────────────────────────────────────
#  存储辅助
# ─────────────────────────────────────────────

<#
.SYNOPSIS
    列出所有卷及类型
.NOTES
    DriveType: 2=可移动, 3=本地磁盘
    参考: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/aa394515(v=vs.85)
#>
function Show-Volumes {
    Get-WmiObject -Class Win32_Volume |
        Select-Object DriveType, Name |
        Format-Table -AutoSize
    Write-Tip '[DriveType] 2: Removable Disk | 3: Local Disk'
}
