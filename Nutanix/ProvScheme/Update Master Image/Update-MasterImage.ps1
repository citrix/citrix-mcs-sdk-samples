<#
.SYNOPSIS
    Update the master image of a provisioning scheme.
.DESCRIPTION
    Update-MasterImage.ps1 updates the master image of a provisioning scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme to be updated.
    2. MasterImage: Literal path to the new master image.
    3. RebootDuration: Maximum time of the reboot cycle in minutes.
    4. WarningDuration: Time in minutes before a reboot when a warning message is shown to users.
    5. WarningRepeatInterval: Intervals of minutes with which the warning message is shown.
    6. WarningMessage: Warning message to display before VMs reboot.
.EXAMPLE
    .\Update-MasterImage.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -MasterImage "XDHyp:\HostingUnits\MyHostingUnit\MyVM.template" `
        -RebootDuration 240 `
        -WarningDuration 0 `
        -WarningRepeatInterval 0 `
        -WarningMessage "Save Your Work"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $ProvisioningSchemeName,
    [Parameter(mandatory=$true)]
    [string] $MasterImage,
    [Parameter(mandatory=$true)]
    [int] $RebootDuration,
    [int] $WarningDuration,
    [Parameter(mandatory=$true)]
    [int] $WarningRepeatInterval,
    [string] $WarningMessage
)
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2" Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2" Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2" 

try{
    & Set-ProvSchemeMetadata -Name "ImageManagementPrep_DoImagePreparation" -ProvisioningSchemeName $ProvisioningSchemeName -Value "True"
}
catch{
    Write-Error $_
    exit
}

try{
    Publish-ProvMasterVMImage -MasterImageVM $MasterImage -ProvisioningSchemeName $ProvisioningSchemeName
}
catch{
    Write-Error $_
    exit
}

$brokerRebootCycleParams = @{
    InputObject = @($ProvisioningSchemeName)
    RebootDuration  = $RebootDuration
    WarningRepeatInterval = $WarningRepeatInterval
}

if($PSBoundParameters.ContainsKey("WarningDuration")){
    $brokerRebootCycleParams.Add("WarningDuration", $WarningDuration)
}

if($PSBoundParameters.ContainsKey("WarningMessage")){
    $brokerRebootCycleParams.Add("WarningMessage", $WarningMessage)
}

Write-Verbose "Restart VMs in the Provisioning Scheme"

try{
    & Start-BrokerRebootCycle @brokerRebootCycleParams
}
catch{
    Write-Error $_
    exit
}