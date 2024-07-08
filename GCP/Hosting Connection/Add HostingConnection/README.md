# Add Hosting Connection
## Overview
The creation of a hosting connection is accomplished using cmdlets New-Item and New-BrokerHypervisorConnection.
Follow links to know more about [New-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html) and [New-BrokerHypervisorConnection](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/New-BrokerHypervisorConnection).

**Note**
1.	Ensure that a service account key is already created. Refer this link to [create a new service account key](https://cloud.google.com/iam/docs/keys-create-delete#creating).
2.  Before you begin the process of creating a hosting connection, make sure you have the necessary permissions. Below are the minimum permissions required -
```
"compute.instanceTemplates.list",
"compute.instances.list",
"compute.networks.list",
"compute.projects.get",
"compute.regions.list",
"compute.subnetworks.list",
"compute.zones.list",
"resourcemanager.projects.get"
```
3. To enable [secure environment for GCP managed traffic](https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-gcp#create-a-secure-environment-for-gcp-managed-traffic), use Create-HostingConnection-WithPrivateGoogleAccess script. Make sure to follow this link for [prerequisites to use private Google access](https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-gcp#requirements-to-create-a-secure-environment-for-gcp-managed-traffic).
4. Please refer to this link to understand [permissions required to create a hosting connection](https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-gcp#creating-a-host-connection).
5. For detailed information on the GCP permissions needed for various operations, please refer to the following link	[Required GCP permissions](https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-gcp#required-gcp-permissions).

## Errors users may encounter during this operation
1. In case of an invalid ZoneName provided, an error message will be displayed stating, "Could not find the zone (ZoneName). Verify the ZoneName exists or try the default Primary."
2. If a hosting connection already exists, an error will occur with the message, "The HypervisorConnection object could not be created as an object with the same name already exists."

## Next steps
1. To retrieve information about a hosting connection, please refer to the scripts in "GCP\Hosting Connections\Get HostingConnection".
2. To update a hosting connection, please refer to the sample scripts in "GCP\Hosting Connections\Update HostingConnection".
3. To create a hosting unit inside a hosting connection, please refer to the scripts in the folder "GCP\Hosting Unit\Add HostingUnit".
4. To remove a hosting connection, please refer to the sample scripts in "GCP\Hosting Connections\Remove HostingConnection".
5. To create a new hosting connection, please refer to the sample scripts in "GCP\Hosting Connections\Add HostingConnection".