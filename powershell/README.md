# Enable .ps1 execution

    get-executionpolicy
    set-executionpolicy remotesigned

# Get-Help

    help ps -S<Tab> # Get-Help Get-Process -ShowWindow
    update-help # slow

# Get-Alias

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