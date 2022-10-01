# Enable .ps1 execution

    get-executionpolicy
    set-executionpolicy remotesigned

# Get-Help

    help ps -S<Tab> # Get-Help Get-Process -ShowWindow
    update-help # slow

# Get-Alias

    Get-Alias | findstr Object

    CommandType     Name                                               Version    Source
    -----------     ----                                               -------    ------
    Alias           % -> ForEach-Object
    Alias           foreach -> ForEach-Object

    Alias           ? -> Where-Object
    Alias           where -> Where-Object

    Alias           echo  -> Write-Output [-InputObject] <PSObject[]>
    Alias           write -> Write-Output

    Alias           tee -> Tee-Object
    Alias           type -> Get-Content
    Alias           wget -> Invoke-WebRequest

# Docs
Quoting: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_quoting_rules

# Code Snippet

    function test($a, $b){
        if ($null -eq $b){}
        Write-Information "don't assign text to returned value" -InformationAction Continue
        return "Named para: $a"
    }

    for ($i=1; $i -eq/ne/gt/ge/lt/le 2; $i++){}
    switch(1){ 1{"a"} default{"x"} }

    [System.Environment]::GetEnvironmentVariable('', 'Process/User/Machine')

    "true/false" -match "\w+"
    "text" | Select-String -Pattern 't'  -All | % { $_.Matches } | % { $_.Value }