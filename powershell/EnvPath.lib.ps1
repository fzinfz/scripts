function Show-EnvPath {
    foreach($target in [EnvironmentVariableTarget].GetEnumNames()){
        "`n- env :: $target :: Path"
        [Environment]::GetEnvironmentVariable('Path', $target) -split ';' | 
            Sort-Object | ForEach-Object {"    $_"}
    }
}

# add path to ($1 + Process) EnvironmentVariableTarget
function Add-EnvPath {
    param(
        [Parameter(Mandatory=$true)]
        [string] $EnvVarTarget,
    
        [Parameter(Mandatory=$true)]
        [string] $Path
    )
    
    $EnvVarTarget, [System.EnvironmentVariableTarget]0 | % {
        $PathList = [Environment]::GetEnvironmentVariable('Path', $_) -split ';'
        if (($PathList -notcontains $Path) -and (Test-Path $Path)) {
            Write-Host -ForegroundColor Green "`n[DEBUG] add env::$_::Path: $Path"
            $PathList = $PathList + $Path | ? { $_ }
            [Environment]::SetEnvironmentVariable('Path', $PathList -join ';', $_)
        }
    }
}