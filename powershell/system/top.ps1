<#
.SYNOPSIS
    CPU and memory real-time usage monitoring script
.DESCRIPTION
    Output:
    - CPU load percentage
    - Top 20 CPU-consuming processes (>1%)
    - Available memory (MB)
    - Top 10 memory-consuming processes (merge same-name processes by working set)
.NOTES
    Refactored from: top.ps1
    Reference: https://stackoverflow.com/a/64080148
#>

. $PSScriptRoot\..\Lib.ps1

# --- CPU --------------------------------------------------------------------
Write-Step 'CPU Load'
Invoke-Steps { Get-WmiObject Win32_Processor | Select-Object Name, LoadPercentage | Format-Table -AutoSize }

Write-Step 'CPU Usage Ranking (Top 20, >1%)'
Get-Counter '\Process(*)\% Processor Time' |
    Select-Object -ExpandProperty CounterSamples |
    Select-Object -Property InstanceName, CookedValue |
    Sort-Object -Property CookedValue -Descending |
    Select-Object -First 20 |
    Where-Object { $_.CookedValue -gt 1 } |
    Format-Table InstanceName,
        @{ L = 'CPU%'; E = { ($_.CookedValue / 100).ToString('P') } } `
        -AutoSize

# --- Memory -----------------------------------------------------------------
Write-Step 'Available Memory'
Invoke-Steps { Get-Counter '\Memory\Available MBytes' | Format-Table }

Write-Step 'Memory Usage Ranking (Top 10, merge same-name processes)'
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