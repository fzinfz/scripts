# PowerShell Scripts 2026

基于最新编程规范重构的 Windows PowerShell 脚本库。

## 目录结构

```
powershell_2026/
├── Lib.ps1                  # 核心公共库（日志、执行、工具函数）
├── EnvPath.ps1              # PATH 环境变量管理
├── Profile.ps1              # PowerShell Profile（由 setup.ps1 部署）
│
├── system/                  # 系统管理
│   ├── setup.ps1            # 环境初始化（一次性运行，需管理员）
│   ├── check_env.ps1        # 系统环境信息检查
│   └── host_info.ps1        # 主机基本信息
│
├── nw/                      # 网络管理
│   ├── Lib.Route.ps1        # 路由工具库
│   ├── check.ps1            # 接口/地址/WAN IP 检查
│   ├── dns_check.ps1        # DNS 查询与缓存搜索
│   ├── firewall.ps1         # 防火墙规则查询
│   ├── ports.ps1            # TCP 监听端口查询
│   ├── reset_net.ps1        # 网络协议栈重置（需管理员）
│   ├── route_switch.ps1     # 路由指标交互调整
│   └── trace_route.ps1      # 交互式 TraceRoute
│
├── hyper-v/                 # Hyper-V 管理
│   ├── check.ps1            # VM/设备状态检查
│   ├── enable_hyper-v.ps1   # 启用 Hyper-V
│   ├── get_cmds.ps1         # 列出相关 PowerShell 命令
│   └── pnp_dismount.ps1     # PnP 设备卸载分配给 VM（DDA）
│
├── fs/                      # 文件系统操作
│   └── ipad_mtp.ps1         # iPad MTP 文件管理（复制/删除）
│
├── my/                      # 个人定制
│   └── shortcut_desktop.ps1 # 桌面快捷方式批量创建
│
├── disk.ps1                 # 磁盘与存储信息
├── top.ps1                  # CPU/内存实时监控
├── openssh_client.ps1       # OpenSSH 客户端配置
├── openssh_server.ps1       # OpenSSH 服务端安装配置（需管理员）
├── eject_removable.ps1      # 弹出可移动磁盘
└── pnp.ps1                  # PnP 设备查询
```

## 快速开始

### 1. 执行策略

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 2. 初始化环境（仅首次，需管理员）

```powershell
.\system\setup.ps1
```

### 3. 按需运行脚本

```powershell
# 查看网络信息
.\nw\check.ps1

# 查看磁盘信息
.\disk.ps1

# 查看 CPU/内存
.\top.ps1
```

## 编程规范

### 核心约束

| 规范项 | 要求 |
|--------|------|
| 严格模式 | `Set-StrictMode -Version Latest` |
| 错误处理 | `$ErrorActionPreference = 'Stop'` |
| 函数命名 | `Verb-Noun` (PascalCase) 或 `verb_noun` (辅助函数) |
| 参数声明 | 必须含 `[Parameter(Mandatory)]` 和类型声明 |
| 管理员检查 | 需提权时加 `#Requires -RunAsAdministrator` |
| 引入方式 | `. $PSScriptRoot\..\Lib.ps1` |

### 日志函数

| 函数 | 颜色 | 用途 |
|------|------|------|
| `Write-Step` | 绿色 | 步骤标题 / 操作说明 |
| `Write-Tip` | 黄色 | 提示信息 / 命令示例 |
| `Write-Info` | 默认 | 普通信息 |
| `Write-Warn` | 红色 | 警告 / 错误 |

### 命令执行函数

| 函数 | 用途 |
|------|------|
| `Invoke-Step $cmd` | 执行单条命令（打印后执行） |
| `Invoke-Steps @'...'@` | 批量执行多行命令 |
| `Invoke-StepWithConfirm $cmd` | 需用户确认后执行 |
| `Assert-Param -Value $v -Name $n` | 参数非空断言 |

### 函数文档模板

```powershell
<#
.SYNOPSIS
    函数简要说明
.DESCRIPTION
    详细说明（可选）
.PARAMETER ParamName
    参数说明
.EXAMPLE
    调用示例
.NOTES
    额外说明
#>
function Verb-Noun {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ParamName
    )
    # ...
}
```

## 与原代码的主要变化

详见 [REFACTORING_CHANGES.md](REFACTORING_CHANGES.md)
