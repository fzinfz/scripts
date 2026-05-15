<#
.SYNOPSIS
    批量执行网络检查脚本
.DESCRIPTION
    依次列出并执行 nw 目录下所有 *_check.ps1 脚本：
    1. 自动执行第一个脚本
    2. 显示下一个脚本名称，等待用户按 Enter 后执行
    3. 重复直到最后一个脚本执行完毕
.NOTES
    按文件名排序执行
#>

. $PSScriptRoot\..\Lib.ps1

$checkFiles = Get-ChildItem -Path $PSScriptRoot -Filter '*_check.ps1' | Sort-Object Name

if ($checkFiles.Count -eq 0) {
    Write-Warn "未找到 *_check.ps1 文件"
    return
}

for ($i = 0; $i -lt $checkFiles.Count; $i++) {
    $file = $checkFiles[$i]

    if ($i -eq 0) {
        Write-Step "[$($i + 1)/$($checkFiles.Count)] 执行: $($file.Name)"
        & $file.FullName
    }
    else {
        Write-Host -ForegroundColor Cyan "`n[$($i + 1)/$($checkFiles.Count)] 下一个: $($file.Name)"
        Invoke-StepsWithConfirm { & $file.FullName }
    }
}

Write-Step '所有检查脚本执行完毕'
