<#
.SYNOPSIS
    Creates the HostingConnection using GCP service account keyless authentication.
.DESCRIPTION
    Create-HostingConnection-Keyless.ps1 creates the HostingConnection when ConnectionName and ZoneName are provided.
    Keyless authentication uses the service account attached to the machine that runs the plugin, so no service account
    JSON key (private key) is stored. Instead of a service account email and private key, the well-known sentinel value
    "gcp_keyless_auth" is supplied as the UserName to request keyless authentication.

    Prerequisites:
        - On-premises: the Delivery Controller must run on a GCE VM that has a service account attached.
        - Citrix Cloud: the Cloud Connector must run on a GCE VM with an attached service account, and the connection
          must proxy hypervisor traffic through the connector (see the CustomProperties note in Step 2).
        - The attached service account must have the permissions required for the resources you intend to manage.
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "GcpConnection"
$ZoneName = "ZoneName"

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

# $CustomProperties is passed to New-Item in Step 2. On-premises uses the empty block below.
# For Citrix Cloud, replace the value with the second block (comment out the first, uncomment the second) so that
# hypervisor traffic is proxied through the Cloud Connector and the connector's attached service account is used.
# You only change the value here; Step 2 already passes -CustomProperties $CustomProperties, so no params edit is needed.
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></CustomProperties>'
# $CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Property Name="ProxyHypervisorTrafficThroughConnector" Value="True" /></CustomProperties>'

# Keyless authentication does not use a service account JSON key. The sentinel "gcp_keyless_auth" is supplied as the
# UserName to request keyless authentication; the password is not used for authentication but a non-empty value is required.
$ServiceAccount_Email = "gcp_keyless_auth"
$ServiceAccount_PrivateKey = ConvertTo-SecureString -String "gcp_keyless_auth" -AsPlainText -Force

##########################
# Step 1: Find Zone Uid. #
##########################

$zone = Get-ConfigZone -Name $ZoneName -ErrorAction 'SilentlyContinue'
$zoneUid = $zone.Uid
if($null -eq $zoneUid)
{
    throw "Could not find the zone (ZoneName): $($ZoneName). Verify the ZoneName exists."
}

#####################################################
# Step 2: Create the hosting connection. #
#####################################################

$connection = New-Item -Path @("XDHyp:\Connections\$($ConnectionName)") `
				-ConnectionType "Custom" `
				-CustomProperties $CustomProperties `
				-HypervisorAddress "http://cloud.google.com" `
				-Persist `
				-PluginId "GcpPluginFactory" `
				-Scope @() `
				-SecurePassword $ServiceAccount_PrivateKey `
				-UserName $ServiceAccount_Email `
				-ZoneUid $zoneUid

#####################################################
# Step 3: Create a broker hosting connection. #
#####################################################

New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid
