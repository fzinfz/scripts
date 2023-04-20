. .\Lib.ps1

Read-Host -Prompt "`nEnter to reset or Ctrl+C to exit"

run '
netsh winsock reset
netsh int ip reset
netcfg -d
'