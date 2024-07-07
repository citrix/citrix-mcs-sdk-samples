<#
.SYNOPSIS
    Roll back the master image of a provisioning scheme.
.DESCRIPTION
    `RollBack-MasterImage.ps1` is designed to roll back the master image of a provisioning scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme to be updated.
    2. RebootDuration: The approximate maximum duration (in minutes) of the reboot cycle.
    3. WarningDuration: The lead time (in minutes) before a reboot when a warning message is shown to users.
    4. WarningRepeatInterval: The interval (in minutes) at which the warning message is repeated.
    5. WarningMessage: The message displayed to users prior to a machine reboot.
    6. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\RollBack-MasterImage.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -RebootDuration 240 `
        -WarningDuration 15 `
        -WarningRepeatInterval 0 `
        -WarningMessage "Save Your Work" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [int] $RebootDuration,
    [int] $WarningDuration,
    [int] $WarningRepeatInterval,
    [string] $WarningMessage,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

######################################################
# Step 1: Get the previous Master Image for Rollback #
######################################################
Write-Output "Step 1: Get the previous Master Image for Rollback."

# Configure the common parameters for Get-ProvSchemeMasterVMImageHistory.
$getProvSchemeMasterVMImageHistoryParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    SortBy = "Date"
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $getProvSchemeMasterVMImageHistoryParameters['AdminAddress'] = $AdminAddress }

# Get the the previous Master Images.
$previousImages =  & Get-ProvSchemeMasterVMImageHistory @getProvSchemeMasterVMImageHistoryParameters

# Get the last Master Image for rollback.
$lastImageForRollback = $previousImages[$previousImages.Count - 1]

#######################################################################################
# Step 2: Remove the previous Master Image for Rollback from the Master Image History #
#######################################################################################
Write-Output "Step 2: Remove the last Master Image for Rollback from the Master Image HIstory."

# Configure the common parameters for Remove-ProvSchemeMasterVMImageHistory.
$removeProvSchemeMasterVMImageHistoryParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    VMImageHistoryUid = $lastImageForRollback.VMImageHistoryUid
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeProvSchemeMasterVMImageHistoryParameters['AdminAddress'] = $AdminAddress }

# Remove the last image from the history as it will be updated from Deleted to Current.
& Remove-ProvSchemeMasterVMImageHistory @removeProvSchemeMasterVMImageHistoryParameters

##############################################################
# Step 3: Update the Master Image of the Provisioning Scheme #
##############################################################
Write-Output "Step 3: Update the image of the Provisioning Scheme."

# Configure the Provisioning Scheme Metadata
# If you need to turn off the Image Prep, you can set the value as False.
# Please find the detail in https://www.citrix.com/blogs/2016/04/04/machine-creation-service-image-preparation-overview-and-fault-finding/
$provSchemeMetadataName = "ImageManagementPrep_DoImagePreparation"
$provSchemeMetadataValue = "True"

# Configure the common parameters for Set-ProvSchemeMetadata.
$setProvSchemeMetadataParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    Name = $provSchemeMetadataName
    Value = $provSchemeMetadataValue
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $setProvSchemeMetadataParameters['AdminAddress'] = $AdminAddress }

# Set the Provisioning Scheme Metadata
& Set-ProvSchemeMetadata @setProvSchemeMetadataParameters

# Configure the common parameters for Publish-ProvMasterVMImage.
$publishProvMasterVMImageParameters = @{
    ProvisioningSchemeName = $ProvisioningSchemeName
    DoNotStoreOldImage  = $true
    MasterImageVM = $lastImageForRollback.MasterImageVM
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $publishProvMasterVMImageParameters['AdminAddress'] = $AdminAddress }

# Update the image of the Provisioning Scheme
$publishProvMasterVMImageResult = & Publish-ProvMasterVMImage @publishProvMasterVMImageParameters
$publishProvMasterVMImageResult

#####################################
# Step 4: Verify the Image Updated #
#####################################
Write-Output "Step 4: Verify the Image Updated."

# Configure the common parameters for Get-ProvSchemeMasterVMImageHistory.
$getProvSchemeMasterVMImageHistoryParameters = @{
    ProvisioningSchemeName = $ProvisioningSchemeName
    ImageStatus  = "Current"
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $getProvSchemeMasterVMImageHistoryParameters['AdminAddress'] = $AdminAddress }

# Check the updated image is added correctly to the image history.
$getProvSchemeMasterVMImageHistoryResult = & Get-ProvSchemeMasterVMImageHistory @getProvSchemeMasterVMImageHistoryParameters

# Check the updated image is added correctly to the ProvScheme.
$getProvSchemeResult = Get-ProvScheme -ProvisioningSchemeName $provisioningSchemeName

# Check the image in the image history and the image in ProvScheme are the same
if ($getProvSchemeMasterVMImageHistoryResult.MasterImageVM -ne $getProvSchemeResult.MasterImageVM) {
    Write-Output "Publish-ProvMasterVMImage Failed."
}

#############################################################
# Step 5: Reboot Machines to apply the updated Master Image #
#############################################################
Write-Output "Step 5: Reboot machines to apply the updated image."

# Configure the common parameters for Start-BrokerRebootCycle.
$startBrokerRebootCycleParameters = @{
    InputObject = @($ProvisioningSchemeName)
    RebootDuration  = $RebootDuration
    WarningMessage = $WarningMessage
    WarningDuration = $WarningDuration
    WarningRepeatInterval = $WarningRepeatInterval
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $startBrokerRebootCycleParameters['AdminAddress'] = $AdminAddress }

# Reboot machines of the Provisioning Scheme
& Start-BrokerRebootCycle @startBrokerRebootCycleParameters

##############################
# Step 6: Remove ProvTask(s) #
##############################
Write-Output "Step 6: # Remove ProvTask(s)."

# Configure the common parameters for Remove-ProvTask.
$removeProvTaskParameters = @{
    TaskId  = $publishProvMasterVMImageResult.TaskId
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeProvTaskParameters['AdminAddress'] = $AdminAddress }

# Remove the task for updating image
& Remove-ProvTask @removeProvTaskParameters
