# Create a ProvsionedVmConfiguration
To create a ProvsionedVmConfiguration, the following parameters are required:
- `ProvisioningSchemeName`
- `VMName`

The following parameters are optional
- `MemoryInMB` 
- `CpuCount`
- `CustomProperties`
- `ServiceOffering`
- `MachineProfile`
- `NetworkMapping`
- `RemoveCustomizations`
- `ConfigurationInfo`

Create the ProvsionedVmConfiguration
```powershell
$provisioningSchemeName = "test"
$VMName = "vm01"
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
$ConfigurationInfo = "ProvisionedVm is being updated with the requirement of customers"

############################################################
# Create ProvisionedVmConfiguration with CPUCount modified
############################################################
New-ProvVmConfiguration
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -CpuCount $CpuCount `
  -VMName $VMName
  
###############################################################
# Create ProvisionedVmConfiguration with MemoryInMB modified
###############################################################
New-ProvVmConfiguration
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -MemoryInMB $MemoryInMB `
  -VMName $VMName
  
#####################################################################
# Create ProvisionedVmConfiguration with CustomProperties modified
#####################################################################
New-ProvVmConfiguration
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -CustomProperties $CustomProperties `
  -VMName $VMName
  
#####################################################################
# Create ProvisionedVmConfiguration with MachineProfile modified
#####################################################################
New-ProvVmConfiguration
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -MachineProfile $MachineProfile `
  -VMName $VMName
  
#####################################################################
# Create ProvisionedVmConfiguration with ServiceOffering modified
#####################################################################
New-ProvVmConfiguration
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -ServiceOffering $ServiceOffering `
  -VMName $VMName
  
#####################################################################
# Create ProvisionedVmConfiguration with NetworkMapping modified
#####################################################################
New-ProvVmConfiguration
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -NetworkMapping $NetworkMapping `
  -VMName $VMName
  
#####################################################################
# Create ProvisionedVmConfiguration with no customizations modified
#####################################################################
New-ProvVmConfiguration
  -ProvisioningSchemeName $provisioningSchemeName `
  -RemoveCustomizations `
  -VMName $VMName
```