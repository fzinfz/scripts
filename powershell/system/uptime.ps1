# 系统运行时间查询脚本
# 功能：查询当前会话运行时间 + 按年份统计累计运行时长

Write-Host "========== 当前会话运行时间 ==========" -ForegroundColor Cyan

$bootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$uptime = (Get-Date) - $bootTime

Write-Host ("系统启动时间 : " + $bootTime.ToString("yyyy-MM-dd HH:mm:ss"))
Write-Host ("已运行时长   : " + $uptime.Days + " 天 " + $uptime.Hours + " 小时 " + $uptime.Minutes + " 分钟")

Write-Host ""
Write-Host "========== 按年份分组统计 ==========" -ForegroundColor Cyan

# 查询系统事件日志中的启动(6009)和关机(6006)记录
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ID = 6006, 6009
} -ErrorAction SilentlyContinue | Sort-Object TimeCreated

$yearly = @{}
$lastBootPerYear = @{}

foreach ($event in $events) {
    $year = $event.TimeCreated.Year
    if (-not $yearly.ContainsKey($year)) {
        $yearly[$year] = @{ Boots = 0; Shutdowns = 0; Uptime = [TimeSpan]::Zero }
    }
    if ($event.Id -eq 6009) {
        $yearly[$year].Boots++
        $lastBootPerYear[$year] = $event.TimeCreated
    }
    elseif ($event.Id -eq 6006) {
        $yearly[$year].Shutdowns++
        if ($lastBootPerYear.ContainsKey($year)) {
            $yearly[$year].Uptime += $event.TimeCreated - $lastBootPerYear[$year]
            $lastBootPerYear.Remove($year)
        }
    }
}

# 累加当前仍在运行的会话时长
foreach ($year in $lastBootPerYear.Keys) {
    if (-not $yearly.ContainsKey($year)) {
        $yearly[$year] = @{ Boots = 0; Shutdowns = 0; Uptime = [TimeSpan]::Zero }
    }
    $yearly[$year].Uptime += (Get-Date) - $lastBootPerYear[$year]
}

# 如果事件日志中缺少当前启动记录，补上当期会话时长
$currentYear = $bootTime.Year
if (-not $lastBootPerYear.ContainsKey($currentYear)) {
    if (-not $yearly.ContainsKey($currentYear)) {
        $yearly[$currentYear] = @{ Boots = 0; Shutdowns = 0; Uptime = [TimeSpan]::Zero }
    }
    $yearly[$currentYear].Uptime += (Get-Date) - $bootTime
    $yearly[$currentYear].Boots++
}

# 输出表格
Write-Host ("{0,-6} {1,-10} {2,-10} {3,-20}" -f "年份", "启动次数", "关机次数", "累计运行时长（估算）")
Write-Host ("{0,-6} {1,-10} {2,-10} {3,-20}" -f "----", "------", "------", "------------------")

foreach ($year in ($yearly.Keys | Sort-Object)) {
    $data = $yearly[$year]
    $uptimeStr = "{0} 天 {1} 小时 {2} 分钟" -f $data.Uptime.Days, $data.Uptime.Hours, $data.Uptime.Minutes
    Write-Host ("{0,-6} {1,-10} {2,-10} {3,-20}" -f $year, $data.Boots, $data.Shutdowns, $uptimeStr)
}

Write-Host ""
Write-Host "注意：累计运行时长基于事件ID 6006/6009 估算，依赖事件日志保留策略。" -ForegroundColor Yellow
