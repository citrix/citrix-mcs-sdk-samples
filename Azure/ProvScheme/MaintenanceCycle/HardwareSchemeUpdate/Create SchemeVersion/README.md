# Create ProvisioningScheme Version
To create a Provisioning Scheme Version, the following parameters are required:
- `ProvisioningSchemeName`

The following parameters are optional
- `MemoryInMB` 
- `CpuCount`
- `CustomProperties`
- `ServiceOffering`
- `ServiceOffering`
- `MachineProfile`
- `NetworkMapping`
- `SecurityGroup`
- `WriteBackCacheDiskSize`
- `WriteBackCacheMemorySize`
- `ConfigurationInfo`

Create the provisioning scheme version
```powershell
$provisioningSchemeName = "test"
$CpuCount = 8
$MemoryInMB = 8192
#Please add custom properties here
$CustomProperties = "AwsCaptureInstanceProperties,true;AwsOperationalResourcesTagging,true"
#Please add service offering here
$ServiceOffering = "XDHyp:\HostingUnits\aws\00000000-0000-0000-0000-000000000000.serviceoffering"
#Please add machine profile here
$MachineProfile = "XDHyp:\HostingUnits\aws\ap-machine-profile (00000000-0000-0000-0000-000000000000).launchtemplate\00000000-0000-0000-0000-000000000000.launchtemplateversion"
#Please add network mapping here
$NetworkMapping = @{"0" = "XDHyp:\HostingUnits\aws\us-east-1a.availabilityzone\00000000-0000-0000-0000-000000000000.network"}
#Please add security group here
$SecurityGroup = "XDHyp:\HostingUnits\aws\00000000-0000-0000-0000-000000000000.securitygroup"
$WriteBackCacheDiskSize = 50
$WriteBackCacheMemorySize = 2048
$ConfigurationInfo = "Provisioning Scheme is being updated with the requirement of customers"

############################################################
# Create Provisioning Scheme Version with CPUCount modified
############################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -CpuCount $CpuCount
  
###############################################################
# Create Provisioning Scheme Version with MemoryInMB modified
###############################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -MemoryInMB $MemoryInMB
  
#####################################################################
# Create Provisioning Scheme Version with CustomProperties modified
#####################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -CustomProperties $CustomProperties
  
#####################################################################
# Create Provisioning Scheme Version with MachineProfile modified
#####################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -MachineProfile $MachineProfile
  
#####################################################################
# Create Provisioning Scheme Version with ServiceOffering modified
#####################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -ServiceOffering $ServiceOffering
  
#####################################################################
# Create Provisioning Scheme Version with NetworkMapping modified
#####################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -NetworkMapping $NetworkMapping
  
#####################################################################
# Create Provisioning Scheme Version with SecurityGroup modified
#####################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -SecurityGroup $SecurityGroup
  
##########################################################################
# Create Provisioning Scheme Version with WriteBackCacheDiskSize modified
##########################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -WriteBackCacheDiskSize $WriteBackCacheDiskSize
  
#############################################################################
# Create Provisioning Scheme Version with WriteBackCacheMemorySize modified
#############################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -WriteBackCacheMemorySize $WriteBackCacheMemorySize
```