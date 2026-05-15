<#
.SYNOPSIS
    CPU 与内存实时占用监控脚本
.DESCRIPTION
    输出：
    - CPU 负载百分比
    - CPU 占用前 20 进程（>1%）
    - 可用内存（MB）
    - 内存占用前 10 进程（按工作集合并同名进程）
.NOTES
    重构自: top.ps1
    参考: https://stackoverflow.com/a/64080148
#>

. $PSScriptRoot\Lib.ps1

# ─── CPU ──────────────────────────────────────
Write-Step 'CPU 负载'
Invoke-Step 'Get-WmiObject Win32_Processor | Select-Object Name, LoadPercentage | Format-Table -AutoSize'

Write-Step 'CPU 占用排行（Top 20，>1%）'
Get-Counter '\Process(*)\% Processor Time' |
    Select-Object -ExpandProperty CounterSamples |
    Select-Object -Property InstanceName, CookedValue |
    Sort-Object -Property CookedValue -Descending |
    Select-Object -First 20 |
    Where-Object { $_.CookedValue -gt 1 } |
    Format-Table InstanceName,
        @{ L = 'CPU%'; E = { ($_.CookedValue / 100).ToString('P') } } `
        -AutoSize

# ─── 内存 ─────────────────────────────────────
Write-Step '可用内存'
Invoke-Step 'Get-Counter "\Memory\Available MBytes" | Format-Table'

Write-Step '内存占用排行（Top 10，同名进程合并）'
Get-Process |
    Group-Object -Property Name -NoElement |
    Where-Object { $_.Count -ge 1 } |
    ForEach-Object {
        [PSCustomObject]@{
            Count     = $_.Count
            'Mem(MB)' = [math]::Round(
                (Get-Process -Name $_.Name |
                    Measure-Object WorkingSet -Sum).Sum / 1MB, 0)
            Name      = $_.Name
        }
    } |
    Sort-Object -Property 'Mem(MB)' -Descending |
    Select-Object -First 10 |
    Format-Table -AutoSize
