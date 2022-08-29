# Enable .ps1 execution

    get-executionpolicy
    set-executionpolicy remotesigned

# Get-Alias

    CommandType     Name                                               Version    Source
    -----------     ----                                               -------    ------
    Alias           % -> ForEach-Object
    Alias           foreach -> ForEach-Object

    Alias           ? -> Where-Object
    Alias           where -> Where-Object

    Alias           tee -> Tee-Object
    Alias           type -> Get-Content
    Alias           wget -> Invoke-WebRequest
    Alias           write -> Write-Output