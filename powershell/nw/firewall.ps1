. .\Lib.ps1

run 'Get-NetFirewallRule -Enabled True | Where-Object {($_.Action -ne "Allow")}'
