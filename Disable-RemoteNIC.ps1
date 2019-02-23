#Requires -Version 5

###############################################################################################################
# Language     :  PowerShell 5.0
# Filename     :  Disable-RemoteNIC.ps1 
# Author        :  Brendan Chamberlain
# Description  :  Disables all NICs on a specified remote device.
# Repository   :  N/A
###############################################################################################################

<#
    .SYNOPSIS
    A script used to remotely disable device network interfaces.
    .DESCRIPTION
    The script can be used to remotely disable network interfaces. This can be helpful in situation where an infected 
    device cannot be easily physically disconnected from the network. Requires WinRM and Windows 10/2016 on the 
    remote device.
    .EXAMPLE
    .\Disable-ConnectedNIC.ps1 -ComputerName computer1 -Credential admin
    .LINK
    N/A
#>
Function Disable-RemoteNIC {
    [CmdletBinding()] 
    Param (
        # Define parameters below, each separated by a comma

        [Parameter(Mandatory = $True, Position = 1, HelpMessage = "Enter your administrator account username.")]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory = $True, Position = 0, HelpMessage = "Enter the computer name you would like to disconnect from the network.")]
        [string]$ComputerName
    )
    Process {
        Try {

            $Session = New-PSSession -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop
            $OSVersion = Invoke-Command -Session $Session -ScriptBlock {[System.Environment]::OSVersion.Version.Major} -ErrorAction Stop

            If ($OSVersion -eq 10) {

                Invoke-Command -Session $Session -ScriptBlock {Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Disable-NetAdapter} -ErrorAction Stop
    
            }
            Else {
     
                Write-Host -ForegroundColor Red "The following error occured: This script only works with Windows 10 or Windows 2016 devices."
    
            }

        }
        Catch {

            Write-Host -ForegroundColor Red "The following error occured:" $Error[0].Exception.TransportMessage
            Break
        }

        Get-PSSession | Where-Object {$_.ComputerName -eq $ComputerName} | Remove-PSSession

    }
}
