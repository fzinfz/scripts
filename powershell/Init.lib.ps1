filter split-lines {
    $_.Split([Environment]::NewLine) | ? {$_.trim() -ne "" }
}

filter run {
    param (
        [Parameter(Mandatory=$true)]
        [string] $commands
    )

    $commands | split-lines | % { 
        Write-Host -ForegroundColor Green "`n[RUN] $_"
        Invoke-Expression $_
    }    
}
