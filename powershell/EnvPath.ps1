<#
.SYNOPSIS
    环境变量 PATH 管理模块
.DESCRIPTION
    提供查看和追加 PATH 环境变量的工具函数。
    支持 Process / User / Machine 三个作用域。
.NOTES
    重构自: EnvPath.lib.ps1
    规范:
    - 函数命名 Verb-Noun, Pascal Case
    - 参数有类型声明和 Mandatory 标注
    - 操作前验证路径是否存在
#>

<#
.SYNOPSIS
    显示所有作用域下的 PATH 环境变量条目
.DESCRIPTION
    分别输出 Machine / User / Process 三个 EnvironmentVariableTarget 下的 PATH，
    每个作用域按字母排序。
#>
function Show-EnvPath {
    foreach ($target in [System.EnvironmentVariableTarget].GetEnumNames()) {
        "`n- env :: $target :: Path"
        [Environment]::GetEnvironmentVariable('Path', $target) -split ';' |
            Sort-Object |
            ForEach-Object { "    $_" }
    }
}

<#
.SYNOPSIS
    将路径追加到指定作用域及 Process 的 PATH 中
.DESCRIPTION
    若路径存在且尚未包含在 PATH 中，则将其追加到 $EnvVarTarget 和 Process 两个
    EnvironmentVariableTarget 的 PATH 里。
.PARAMETER EnvVarTarget
    目标作用域名称，可选 Machine / User / Process
.PARAMETER Path
    要追加的目录路径（绝对路径）
.EXAMPLE
    Add-EnvPath -EnvVarTarget User -Path 'D:\sdk\flutter\bin'
#>
function Add-EnvPath {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Machine', 'User', 'Process')]
        [string]$EnvVarTarget,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Warning "路径不存在，跳过: $Path"
        return
    }

    # 同时更新 $EnvVarTarget 和 Process 两个作用域
    $EnvVarTarget, [System.EnvironmentVariableTarget]::Process | ForEach-Object {
        $pathList = [Environment]::GetEnvironmentVariable('Path', $_) -split ';'
        if ($pathList -notcontains $Path) {
            Write-Host -ForegroundColor Green "`n[INFO] Add env::${_}::Path: $Path"
            $pathList = ($pathList + $Path) | Where-Object { $_ }
            [Environment]::SetEnvironmentVariable('Path', ($pathList -join ';'), $_)
        }
    }
}
