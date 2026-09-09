<#
.SYNOPSIS
    Adds one or more scopes to an existing image definition.
.DESCRIPTION
    Add-ImageDefinitionScope.ps1 adds the specified scope(s) to an existing image definition.
    The original version of this script is compatible with Citrix DaaS DDC 129.
.INPUTS
    1. DefinitionName: Name(s) of the image definition.
    2. Scope: One or more scope names to add to the image definition.
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string[]]$DefinitionName,
    [string[]]$Scope
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

Add-ProvImageDefinitionScope -ImageDefinitionName $DefinitionName -Scope $Scope
