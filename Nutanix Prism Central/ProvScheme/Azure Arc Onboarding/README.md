# MCS Azure Arc Onboarding
## Overview
When using MCS to manage machines hosted outside of Azure (on-prem or other cloud) in a catalog, you can onboard the machines to Azure Arc to leverage some of Azure's capabilities such as Azure Monitor.

## Prerequisites
VDAs must be higher than 2311 with AzureConnectedMachineAgent installed. This agent can be downloaded from https://aka.ms/AzureConnectedMachineAgent.
Azure Service Principle must be assigned "Azure Connected Machine Resource Administrator" role.
A ResourceGroup is created on Azure portal where machines needs to be onboarded

## How to enable Azure Arc on a ProvScheme
You can enable Azure Arc Onboarding for any ProvScheme using the parameters:
* EnableAzureArcOnboarding 
* AzureArcSubscriptionId
* AzureArcResourceGroup
* AzureArcRegion
When the Parameter `EnableAzureArcOnboarding` is specified, the rest of the Arc parameters are mandatory.

[Create-ProvScheme-WithAzureArc.ps1](Create-ProvScheme-WithAzureArc.ps1) gives a simple example on how to create a catalog with Arc Onboarding enabled.
NOTE: Before creating a catalog, ensure the IdentityPool is created using an appropriate script under .\Nutanix Prism Central\Identity\Create IdentityPool.

[Update-ProvScheme-EnableAzureArc.ps1](Update-ProvScheme-EnableAzureArc.ps1) gives a simple example on how to enable Arc Onboarding on an existing catalog.
[Update-ProvScheme-DisableAzureArc.ps1](Update-ProvScheme-DisableAzureArc.ps1) gives a simple example on how to disable Arc Onboarding on an existing catalog. 

Documentation: https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create.html#onboard-vms-to-azure-arc