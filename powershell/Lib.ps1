function tip {
    Write-Host -ForegroundColor Yellow `n[TIP] $args[0]
}

filter split-lines {
    $_.Split([Environment]::NewLine) | ? { $_.trim() -ne "" }
}

function run {
    param (
        [Parameter(Mandatory=$true)]
        [string] $commands
    )

    "$commands".Split([Environment]::NewLine) | ? {$_.trim() -ne "" } | % {
        Write-Host -ForegroundColor Green "`n[RUN] $_"
        Invoke-Expression $_
    }
}

function check_volume() { 
    get-wmiobject -Class Win32_Volume | select DriveType, Name | ft 
    Write-Host -ForegroundColor Yellow "[DriveType] 2: Removable Disk | 3: Local Disk | More: https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/aa394515(v=vs.85)"
}