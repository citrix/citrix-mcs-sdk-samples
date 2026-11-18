<#
.SYNOPSIS
    Creates a Provisioning Scheme Version for Hardware Update on XenServer. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-SchemeVersion creates a Provisioning Scheme Version with modified hardware properties.
    Supports CpuCount, MemoryMB, MachineProfile, CustomProperties, NetworkMapping,
    WriteBackCacheDiskSize, and WriteBackCacheMemorySize.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#####################
# Prepare Parameters
#####################
$provisioningSchemeName = "test"
$CpuCount = 8
$MemoryMB = 8192
#Please add machine profile here for XenServer
$MachineProfile = "XDHyp:\HostingUnits\XenServerUnit\<profile-vm>.vm"
#Please add custom properties here
$CustomProperties = "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"><Property xsi:type=`"StringProperty`" Name=`"CpuCount`" Value=`"8`" /></CustomProperties>"
#Please add network mapping here for XenServer
$NetworkMapping = @{"0" = "XDHyp:\HostingUnits\XenServerUnit\<network-name>.network"}
$WriteBackCacheDiskSize = 50
$WriteBackCacheMemorySize = 2048
$ConfigurationInfo = "Provisioning Scheme is being updated with the requirement of customers"

############################################################
# Create Provisioning Scheme Version with CpuCount modified
############################################################
New-ProvSchemeVersion `
  -ProvisioningSchemeName $provisioningSchemeName `
  -CpuCount $CpuCount

###############################################################
# Create Provisioning Scheme Version with MemoryMB modified
###############################################################
New-ProvSchemeVersion `
  -ProvisioningSchemeName $provisioningSchemeName `
  -MemoryMB $MemoryMB

#####################################################################
# Create Provisioning Scheme Version with MachineProfile modified
#####################################################################
New-ProvSchemeVersion `
  -ProvisioningSchemeName $provisioningSchemeName `
  -MachineProfile $MachineProfile

#####################################################################
# Create Provisioning Scheme Version with CustomProperties modified
#####################################################################
New-ProvSchemeVersion `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -CustomProperties $CustomProperties

#####################################################################
# Create Provisioning Scheme Version with NetworkMapping modified
#####################################################################
New-ProvSchemeVersion `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -NetworkMapping $NetworkMapping

##########################################################################
# Create Provisioning Scheme Version with WriteBackCacheDiskSize modified
##########################################################################
New-ProvSchemeVersion `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -WriteBackCacheDiskSize $WriteBackCacheDiskSize

#############################################################################
# Create Provisioning Scheme Version with WriteBackCacheMemorySize modified
#############################################################################
New-ProvSchemeVersion `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -WriteBackCacheMemorySize $WriteBackCacheMemorySize
