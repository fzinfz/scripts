#Requires -Version 5.1
<#
.SYNOPSIS
    Check computer printer list and status.
.DESCRIPTION
    Lists installed printers, their ports, drivers, and current status.
    Falls back to CIM/WMI if the PrintManagement module is not available.
#>

[CmdletBinding()]
param()

$hasPrintManagement = $null

try {
    $hasPrintManagement = Get-Module -ListAvailable -Name PrintManagement -ErrorAction Stop
} catch {
    $hasPrintManagement = $null
}

$printers = @()

if ($hasPrintManagement) {
    try {
        $printers = Get-Printer -ErrorAction Stop | ForEach-Object {
            [PSCustomObject]@{
                Name            = $_.Name
                ShareName       = $_.ShareName
                PortName        = $_.PortName
                DriverName      = $_.DriverName
                Status          = $_.PrinterStatus
                Default         = $_.Default
                Shared          = $_.Shared
                Published       = $_.Published
                Type            = 'Local/Network'
            }
        }
    } catch {
        Write-Warning "Get-Printer failed: $($_.Exception.Message). Falling back to CIM."
        $printers = @()
    }
}

if (-not $printers) {
    $cimPrinters = Get-CimInstance -ClassName Win32_Printer -ErrorAction SilentlyContinue
    if (-not $cimPrinters) {
        $cimPrinters = Get-WmiObject -Class Win32_Printer -ErrorAction SilentlyContinue
    }

    foreach ($p in $cimPrinters) {
        $statusText = switch ($p.PrinterStatus) {
            1 { 'Other' }
            2 { 'Unknown' }
            3 { 'Idle' }
            4 { 'Printing' }
            5 { 'Warmup' }
            6 { 'Stopped printing' }
            7 { 'Offline' }
            default { "Unknown ($($p.PrinterStatus))" }
        }

        $printers += [PSCustomObject]@{
            Name       = $p.Name
            ShareName  = $p.ShareName
            PortName   = $p.PortName
            DriverName = $p.DriverName
            Status     = $statusText
            Default    = $p.Default
            Shared     = $p.Shared
            Published  = $p.Published
            Type       = if ($p.Network) { 'Network' } else { 'Local' }
        }
    }
}

if (-not $printers) {
    Write-Host 'No printers found.' -ForegroundColor Yellow
    exit 0
}

$defaultPrinter = $printers | Where-Object { $_.Default -eq $true }

Write-Host "`nInstalled Printers: $($printers.Count)" -ForegroundColor Cyan
if ($defaultPrinter) {
    Write-Host "Default Printer : $($defaultPrinter.Name)" -ForegroundColor Green
}
Write-Host ('-' * 60)

$printers | Format-Table -AutoSize -Property Name, Status, Default, Shared, Type, PortName, DriverName

Write-Host "`nDetailed Printer Information:" -ForegroundColor Cyan
Write-Host ('-' * 60)

foreach ($printer in $printers) {
    $color = if ($printer.Default) { 'Green' } elseif ($printer.Status -eq 'Offline' -or $printer.Status -like '*error*') { 'Red' } else { 'White' }
    Write-Host "Name       : $($printer.Name)" -ForegroundColor $color
    Write-Host "  Status   : $($printer.Status)"
    Write-Host "  Default  : $($printer.Default)"
    Write-Host "  Shared   : $($printer.Shared)"
    Write-Host "  Type     : $($printer.Type)"
    Write-Host "  Port     : $($printer.PortName)"
    Write-Host "  Driver   : $($printer.DriverName)"
    Write-Host ''
}
