. .\Lib.ps1

run Get-DnsClientServerAddress

$search_keyword = Read-Host -Prompt "`nGet-DnsClientCache | findstr "
Get-DnsClientCache | findstr $search_keyword