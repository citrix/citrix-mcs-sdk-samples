<#
.SYNOPSIS
    Update high-availability servers of an existing hosting connection.
.DESCRIPTION
    The `Update-HighAvailabilityServer` script is designed to update high-availability servers of an existing hosting connection.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ConnectionName: The name of the hosting connection to update.
    2. HypervisorAddress: The IP addresses of hypervisors.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Update-HighAvailabilityServer `
        -ConnectionName "MyConnection" `
        -HypervisorAddress "http://88.88.88.88","http://88.88.88.89"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ConnectionName,
    [string[]] $HypervisorAddress
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*


# Convert the input to arrays
$HypervisorAddress = @($HypervisorAddress)

# Configure the Literal Path of the connection
$literalPath = @("XDHyp:\Connections\" + $ConnectionName)

#############################################
# Step 1: Update High-Availability Servers. #
#############################################
Set-Item -LiteralPath $literalPath -HypervisorAddress $HypervisorAddress
