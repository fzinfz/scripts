<#
.SYNOPSIS
    Network stack reset script
.DESCRIPTION
    Execute in sequence:
    - netsh winsock reset
    - netsh int ip reset
    - netcfg -d (remove all network protocol and driver bindings)
    Reboot is usually required after reset.
.NOTES
    Refactored from: nw\reset_net.ps1
    Requires administrator privileges
#>

#Requires -RunAsAdministrator

. $PSScriptRoot\..\Lib.ps1

Write-Warn 'This operation will reset the network stack. A reboot may be required afterwards!'
Read-Host -Prompt 'Press Enter to continue, Ctrl+C to cancel'

Invoke-Steps {
    netsh winsock reset
    netsh int ip reset
    netcfg -d
}

Write-Tip 'Operation complete. It is recommended to restart the system for changes to take effect.'