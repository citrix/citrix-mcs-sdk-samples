<#
.SYNOPSIS
    Sets or changes the BackupVmConfiguration Custom Property on an existing MCS VM.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Set-ProvVmBackupVmConfigurationWithSpot.ps1 helps change the BackupVmConfiguration configuration on an existing MCS VM.
    In this example, the BackupVmConfiguration custom property on the ProvVM is updated to a new list.

#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for Set-ProvVM
$provisioningSchemeName = "demo-provScheme"
$provisionedVmName = "demo-vm-001"

# Update the CustomProperties to include the new value for BackupVmConfiguration consisting of ServiceOfferings with a mix of Spot and Regular priorities
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type=`"StringProperty`" Name=`"BackupVmConfiguration`" Value=`"[{&quot;ServiceOffering&quot;: &quot;Standard_D4a_v4&quot;, &quot;Type&quot;: &quot;Spot&quot;}, {&quot;ServiceOffering&quot;: &quot;Standard_D8a_v4&quot;, &quot;Type&quot;: &quot;Regular&quot;}]`"/>
</CustomProperties>
"@

# Modify the Provisioned VM
Set-ProvVM -VMName $provisionedVmName -ProvisioningSchemeName $provisioningSchemeName -CustomProperties $customProperties

# Schedules existing VM to be updated with the new configuration on the next power on
Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName $provisioningSchemeName -VMName $provisionedVmName -StartsNow