<#
.SYNOPSIS
    Environment Variable PATH Management Module
.DESCRIPTION
    Provides utility functions to view and append PATH environment variables.
    Supports Process / User / Machine scopes.
.NOTES
    Refactored from: EnvPath.lib.ps1
    Conventions:
    - Function names use Verb-Noun, Pascal Case
    - Parameters have type declarations and Mandatory annotations
    - Verifies path existence before operation
#>

<#
.SYNOPSIS
    Displays PATH environment variable entries across all scopes
.DESCRIPTION
    Outputs PATH for each EnvironmentVariableTarget (Machine / User / Process),
    sorted alphabetically per scope.
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
    Appends a path to the specified scope and Process PATH
.DESCRIPTION
    If the path exists and is not already in PATH, appends it to both
    $EnvVarTarget and Process EnvironmentVariableTarget PATH.
.PARAMETER EnvVarTarget
    Target scope name: Machine / User / Process
.PARAMETER Path
    The directory path to append (absolute path)
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
        Write-Warning "Path does not exist, skipping: $Path"
        return
    }

    # Update both $EnvVarTarget and Process scopes
    $EnvVarTarget, [System.EnvironmentVariableTarget]::Process | ForEach-Object {
        $pathList = [Environment]::GetEnvironmentVariable('Path', $_) -split ';'
        if ($pathList -notcontains $Path) {
            Write-Host -ForegroundColor Green "`n[INFO] Add env::${_}::Path: $Path"
            $pathList = ($pathList + $Path) | Where-Object { $_ }
            [Environment]::SetEnvironmentVariable('Path', ($pathList -join ';'), $_)
        }
    }
}
