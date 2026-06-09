#Requires -Version 5.1
<#
.SYNOPSIS
    List offline printers, ask for confirmation, and remove them.
.DESCRIPTION
    Queries installed printers, identifies those with Offline status,
    displays them, prompts for confirmation, and removes them.
    Falls back to CIM/WMI if the PrintManagement module is not available.
#>

[CmdletBinding()]
param()

function Get-PrinterList {
    $printers = @()
    $hasPrintManagement = $null

    try {
        $hasPrintManagement = Get-Module -ListAvailable -Name PrintManagement -ErrorAction Stop
    } catch {
        $hasPrintManagement = $null
    }

    if ($hasPrintManagement) {
        try {
            $printers = Get-Printer -ErrorAction Stop | ForEach-Object {
                [PSCustomObject]@{
                    Name       = $_.Name
                    PortName   = $_.PortName
                    DriverName = $_.DriverName
                    Status     = $_.PrinterStatus
                    Default    = $_.Default
                    Network    = $_.Type -eq 'Connection'
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
                PortName   = $p.PortName
                DriverName = $p.DriverName
                Status     = $statusText
                Default    = $p.Default
                Network    = $p.Network
            }
        }
    }

    return $printers
}

$allPrinters = Get-PrinterList

if (-not $allPrinters) {
    Write-Host 'No printers found.' -ForegroundColor Yellow
    exit 0
}

$offlinePrinters = $allPrinters | Where-Object { $_.Status -eq 'Offline' }

if (-not $offlinePrinters) {
    Write-Host 'No offline printers found.' -ForegroundColor Green
    exit 0
}

Write-Host "`nOffline Printers Found: $($offlinePrinters.Count)" -ForegroundColor Cyan
Write-Host ('-' * 60)
$offlinePrinters | Format-Table -AutoSize -Property Name, Status, PortName, DriverName

$confirmation = Read-Host "Do you want to remove these offline printers? [Y/N]"

if ($confirmation -notmatch '^[Yy]') {
    Write-Host 'Operation cancelled by user.' -ForegroundColor Yellow
    exit 0
}

$hasPrintManagement = $null
try {
    $hasPrintManagement = Get-Module -ListAvailable -Name PrintManagement -ErrorAction Stop
} catch {
    $hasPrintManagement = $null
}

$removed = @()
$failed = @()

foreach ($printer in $offlinePrinters) {
    try {
        if ($hasPrintManagement) {
            Remove-Printer -Name $printer.Name -ErrorAction Stop
        } else {
            $cimPrinter = Get-CimInstance -ClassName Win32_Printer -Filter "Name='$(($printer.Name).Replace('\', '\\'))'" -ErrorAction SilentlyContinue
            if (-not $cimPrinter) {
                $cimPrinter = Get-WmiObject -Class Win32_Printer -Filter "Name='$(($printer.Name).Replace('\', '\\'))'" -ErrorAction SilentlyContinue
            }
            if ($cimPrinter) {
                $result = Invoke-CimMethod -InputObject $cimPrinter -MethodName Delete -ErrorAction Stop
                if ($result.ReturnValue -ne 0) {
                    throw "CIM Delete returned code $($result.ReturnValue)"
                }
            } else {
                throw "Printer instance not found via CIM/WMI."
            }
        }
        $removed += $printer.Name
        Write-Host "Removed: $($printer.Name)" -ForegroundColor Green
    } catch {
        $failed += $printer.Name
        Write-Warning "Failed to remove '$($printer.Name)': $_"
    }
}

Write-Host "`nDone. Removed: $($removed.Count), Failed: $($failed.Count)" -ForegroundColor Cyan
