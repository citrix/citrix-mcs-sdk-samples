<#
.SYNOPSIS
    Update the master image of a provisioning scheme.
.DESCRIPTION
    Update-MasterImage.ps1 updates the master image of a provisioning scheme.
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
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
        -MasterImage "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
        -RebootDuration 240 `
        -WarningDuration 0 `
        -WarningRepeatInterval 0 `
        -WarningMessage "Save Your Work"
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]  [string] $ProvisioningSchemeName,
    [Parameter(mandatory=$true)]  [string] $MasterImage,
    [Parameter(mandatory=$true)]  [int]    $RebootDuration,
    [Parameter(mandatory=$true)]  [int]    $WarningRepeatInterval,
    [Parameter(mandatory=$false)] [int]    $WarningDuration,
    [Parameter(mandatory=$false)] [string] $WarningMessage
)

Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"


try
{
    Write-Output "+ Set-ProvSchemeMetadata ..."
    & Set-ProvSchemeMetadata -Name "ImageManagementPrep_DoImagePreparation" -ProvisioningSchemeName $ProvisioningSchemeName -Value "True"
}
catch
{
    Write-Error "Set-ProvSchemeMetadata: $($_)"
    exit
}

try
{
    Write-Output "+ Publish-ProvMasterVMImage ..."
    Publish-ProvMasterVMImage -MasterImageVM $MasterImage -ProvisioningSchemeName $ProvisioningSchemeName
}
catch
{
    Write-Error "Publish-ProvMasterVMImage: $($_)"
    exit
}


$brokerCatalog = Get-BrokerCatalog -Name $ProvisioningSchemeName -ErrorAction SilentlyContinue

if ($null -eq $brokerCatalog)
{
    Write-Output "Associated Broker Catalog not found for Provisioning Scheme $($ProvisioningSchemeName)"
}
else
{
    $brokerRebootCycleParams = @{
        InputObject = @($ProvisioningSchemeName)
        RebootDuration  = $RebootDuration
        WarningRepeatInterval = $WarningRepeatInterval
    }

    if($PSBoundParameters.ContainsKey("WarningDuration"))
    {
        $brokerRebootCycleParams.Add("WarningDuration", $WarningDuration)
    }

    if($PSBoundParameters.ContainsKey("WarningMessage"))
    {
        $brokerRebootCycleParams.Add("WarningMessage", $WarningMessage)
    }

    Write-Verbose "Restart VMs in the Provisioning Scheme"


    try
    {
        Write-Output "+ Start-BrokerRebootCycle ..."
        & Start-BrokerRebootCycle @brokerRebootCycleParams
    }
    catch
    {
        Write-Error "Start-BrokerRebootCycle: $($_)"
        exit
    }
}