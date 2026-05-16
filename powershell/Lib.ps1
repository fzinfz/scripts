<#
.SYNOPSIS
    PowerShell Common Utility Library - 2026 Edition
.DESCRIPTION
    Provides unified logging output, command execution, interactive helpers, and other core functions.
    All feature scripts import this via . .\Lib.ps1 or . $PSScriptRoot\..\Lib.ps1.
.NOTES
    Conventions:
    - Function names use Verb-Noun PascalCase, or snake_case for helper functions
    - Logging functions: Write-Info / Write-Tip / Write-Step / Write-Warn
    - Command execution: Invoke-Steps (executes script blocks and prints the command itself)
    - Parameter validation: Assert-Param
    - Color conventions: Green=success/execution, Yellow=tip/warning, Red=error, Cyan=title/info
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ─────────────────────────────────────────────
#  Version Info
# ─────────────────────────────────────────────

$PSVersionTable | Format-Table

# ─────────────────────────────────────────────
#  Regex Constants
# ─────────────────────────────────────────────

$Script:pattern_ip = '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'

# ─────────────────────────────────────────────
#  Logging Output
# ─────────────────────────────────────────────

<#
.SYNOPSIS
    Outputs a green step heading
.PARAMETER Message
    Step description text
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
    Outputs a yellow tip message
.PARAMETER Message
    Tip text
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
    Outputs a blue informational message
.PARAMETER Message
    Info text
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
    Outputs a red warning/error
.PARAMETER Message
    Warning text
#>
function Write-Warn {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    Write-Host -ForegroundColor Red "`n[WARN] $Message"
}

# ─────────────────────────────────────────────
#  Command Execution
# ─────────────────────────────────────────────

<#
.SYNOPSIS
    Executes a command and prints the command itself (in green)
.PARAMETER ScriptBlock
    The script block to execute
#>
function Invoke-Steps {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock
    )

    begin {
        $expanded = $ScriptBlock.ToString()
        # Expand $variable references in the script block to their actual values in the current scope
        $expanded = [regex]::Replace($expanded, '\$(\w+)', {
            param($match)
            $varName = $match.Groups[1].Value
            $varValue = Get-Variable -Name $varName -ValueOnly -ErrorAction SilentlyContinue
            if ($null -ne $varValue) {
                return $varValue.ToString()
            }
            return $match.Value
        })
        Write-Host -ForegroundColor Green "`n[RUN] $expanded"
    }

    process {
        & $ScriptBlock
    }
}

<#
.SYNOPSIS
    Prompts for confirmation before executing a command
.PARAMETER Command
    The command string to execute
#>
function Invoke-StepWithConfirm {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    Read-Host -Prompt "`nPress Enter to run: $Command"
    Invoke-Steps { Invoke-Expression $Command }
}

<#
.SYNOPSIS
    Prompts for confirmation before executing a script block
.PARAMETER ScriptBlock
    The script block to execute
#>
function Invoke-StepsWithConfirm {
    param(
        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock
    )
    Read-Host -Prompt "`nPress Enter to run: $ScriptBlock"
    Invoke-Steps $ScriptBlock
}

# ─────────────────────────────────────────────
#  Parameter Validation
# ─────────────────────────────────────────────

<#
.SYNOPSIS
    Asserts that a parameter is not empty/null, otherwise throws an exception
.PARAMETER Value
    The value to check
.PARAMETER Name
    The parameter name (used in the error message)
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
        throw "Required parameter '$Name' cannot be empty"
    }
}

# ─────────────────────────────────────────────
#  Pipeline Filters
# ─────────────────────────────────────────────

<#
.SYNOPSIS
    Filter: splits a multi-line string by lines and removes empty lines
#>
filter Split-Lines {
    $_.Split([Environment]::NewLine) | Where-Object { $_.Trim() -ne '' }
}

# ─────────────────────────────────────────────
#  Storage Helpers
# ─────────────────────────────────────────────

<#
.SYNOPSIS
    Lists all volumes and their types
.NOTES
    DriveType: 2=Removable, 3=Local Disk
    Ref: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/aa394515(v=vs.85)
#>
function Show-Volumes {
    Get-WmiObject -Class Win32_Volume |
        Select-Object DriveType, Name |
        Format-Table -AutoSize
    Write-Tip '[DriveType] 2: Removable Disk | 3: Local Disk'
}
