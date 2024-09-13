
# set variable VMwareSessionId to hold session info
$global:VMwareSessionId = $null


 [string] $VMwareSessionId
    function ConnectToVMware() {
        <#
        .SYNOPSIS
        Connect to vSphere
        .DESCRIPTION
        .PARAMETER ServerAddress
        The address of the vSphere server to connect to.
        .PARAMETER UserName
        The username to use to connect to the vSphere server.
        .PARAMETER Password
        The password to use to connect to the vSphere server.
        .EXAMPLE
        ConnectToVMware -ServerAddress "https://vcenter.example.com" -UserName "username" -Password "SecureString"
        #>
        # /*************************************************************************
        # * Copyright © 2024. Cloud Software Group, Inc.
        # * This file is subject to the license terms contained
        # * in the license file that is distributed with this file.
        # *************************************************************************/
        param(

                [Parameter(Mandatory = $true)]
                [string] $ServerAddress,

                [Parameter(Mandatory = $true)]
                [string] $UserName,

                [Parameter(Mandatory = $true)]
                [SecureString] $Password
        )

        # setup environment
        # Import the VMware PowerCLI module by calling InstallVMwarePowerCLI
        if(InstallVMwarePowerCLI)
            {
			    Write-Information "VMware PowerCLI module is installed" -InformationAction Continue
		    }
		else {
			    Write-Information "Error installing VMware PowerCLI module" -InformationAction Continue
			    throw
		}
        try {
      
            # Connect to vSphere
            $formattedHypervisorAdd = $ServerAddress.replace("https://", "").replace("http://", "")
            $creds = new-object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $Password
            Write-Information   "Connecting to VIServer: $formattedHypervisorAdd" -InformationAction Continue

            if ($null -eq $global:VMwareSessionId) {
                Write-Information "Connecting to VIServer: '$formattedHypervisorAdd', new connection" -InformationAction Continue
                 $vmwarecon = Connect-VIServer $formattedHypervisorAdd  -Credential $creds -Force
            }
            else {
                Write-Information "Connecting to VIServer: '$formattedHypervisorAdd', reusing existing session $($global:VMwareSessionId)" -InformationAction Continue
                $vmwarecon = Connect-VIServer -Server $formattedHypervisorAdd -Credential $creds -Force -Session $global:VMwareSessionId
            }

            $global:VMwareSessionId = $vmwarecon.SessionId
            Write-Information "Connected to VIServer: '$formattedHypervisorAdd', Session: $($global:VMwareSessionId)" -InformationAction Continue
        }
        catch {
            Write-Information "Error returned while connecting, error: $($_.Exception.Message)" -InformationAction Continue
            $global:VMwareSessionId = $null
            throw
        }
    }

    # Disconnect from vSphere

    function DisconnectFromVMware() {
      <#
        .SYNOPSIS
        Disconnect from vSphere
        .DESCRIPTION
        .PARAMETER ServerAddress
        The address of the vSphere server to disconnect from.
        .EXAMPLE
        DisconnectFromVMware -ServerAddress "https://vcenter.example.com"
        #>
         param(
                    [Parameter(Mandatory = $true)]
                    [string] $ServerAddress
            )
        # Disconnect from vSphere
        $formattedHypervisorAdd = $ServerAddress.replace("https://", "").replace("http://", "")
	    Write-Information "Disconnecting from VIServer: '$formattedHypervisorAdd'" -InformationAction Continue
	    Disconnect-VIServer -Server $formattedHypervisorAdd -Force -Confirm:$false
	    $global:VMwareSessionId = $null
	    Write-Information  "Disconnected from VIServer: '$formattedHypervisorAdd'" -InformationAction Continue
    }


# install VMware powerCLI if not already installed
    function InstallVMwarePowerCLI() {
	    if (-not (Get-Module -Name "VMware.PowerCLI" -ListAvailable)) {
		    Write-Information "Installing VMware PowerCLI"  -InformationAction Continue
            Install-Module -Name PowerShellGet -Force -AllowClobber -SkipPublisherCheck
		    Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force -AllowClobber
	    }
        else {
		    Write-Information  "VMware PowerCLI is already installed"  -InformationAction Continue
	    }

        if (-not (Get-Module -Name "VMware.PowerCLI")) {
                Write-Information "Importing VMware PowerCLI module."  -InformationAction Continue
                Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false
                Import-Module -Name @("VMware.PowerCLI") -Force
                Write-Information "Importing VMware PowerCLI module done"  -InformationAction Continue
        }
        else {
                Write-Information "VMware PowerCLI module is already imported"  -InformationAction Continue
        }
        return $true
    }

  
   


