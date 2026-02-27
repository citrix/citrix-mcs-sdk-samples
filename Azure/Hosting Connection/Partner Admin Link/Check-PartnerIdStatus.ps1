<#
.SYNOPSIS
    Checks the current Partner Admin Link (PAL) status for an Azure identity.
.DESCRIPTION
    Check-PartnerIdStatus.ps1 authenticates with an Azure identity and checks if a Partner ID is currently associated.
    This script uses Azure PowerShell cmdlets to verify the PAL status.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
# For Managed Identities, see the authentication section below for alternative methods
$ServicePrincipalId = "your-service-principal-id"  # Application (Client) ID - the same credential used for your Citrix hypervisor connection
$TenantId = "your-tenant-id"
$SubscriptionId = "your-subscription-id"
$secureUserInput = Read-Host 'Please enter your application secret' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$SecretId = ConvertTo-SecureString -String $encryptedInput

##############################################################
# Step 1: Authenticate with Azure                           #
##############################################################

# Note - Installing the Az.ManagementPartner module is a prerequisite for this script.
Import-Module Az.ManagementPartner
Write-Output "Authenticating with Azure..."

# This script demonstrates authentication with a Service Principal.
# For other identity types, replace this section with one of the following:
#
# For System Assigned Managed Identity:
#   Connect-AzAccount -Identity -SubscriptionId $SubscriptionId
#
# For User Assigned Managed Identity:
#   Connect-AzAccount -Identity -AccountId "<client-id>" -SubscriptionId $SubscriptionId

# Service Principal Authentication
$credential = New-Object System.Management.Automation.PSCredential($ServicePrincipalId, $SecretId)

try {
    Connect-AzAccount -ServicePrincipal -TenantId $TenantId -SubscriptionId $SubscriptionId -Credential $credential -ErrorAction Stop | Out-Null
    Write-Output "Successfully authenticated with Azure"
} catch {
    Write-Output "Failed to authenticate with Azure: $_"
    exit 1
}

##############################################################
# Step 2: Check current Partner ID status                   #
##############################################################

Write-Output "Checking current Partner Admin Link status..."

try {
    $partnerInfo = Get-AzManagementPartner -ErrorAction Stop

    if ($partnerInfo) {
        Write-Output "Partner ID is currently associated:"
        Write-Output $partnerInfo
    } else {
        Write-Output "`nNo Partner ID is currently associated with this identity."
    }
} catch {
    if ($_.Exception.Message -match "This user or service principal is not linked with a Partner ID") {
        Write-Output "No Partner ID is currently associated with this identity."
    } else {
        Write-Output "Error checking Partner ID status: $_"
    }
}

# Disconnect from Azure
Disconnect-AzAccount