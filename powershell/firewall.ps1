. .\Lib.ps1

tip "!Allow"
Get-NetFirewallRule -Enabled True | Where-Object {($_.Action -ne "Allow")}