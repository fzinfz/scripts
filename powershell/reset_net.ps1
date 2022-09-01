. .\Lib.ps1

run '
netsh winsock reset
netsh int ip reset
netcfg -d
'