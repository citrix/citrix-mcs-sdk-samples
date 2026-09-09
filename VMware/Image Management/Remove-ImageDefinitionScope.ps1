<#
.SYNOPSIS
    Removes one or more scopes from an existing image definition.
.DESCRIPTION
    Remove-ImageDefinitionScope.ps1 removes the specified scope(s) from an existing image definition.
    The original version of this script is compatible with Citrix DaaS DDC 129.
.INPUTS
    1. DefinitionName: Name(s) of the image definition.
    2. Scope: One or more scope names to remove from the image definition.
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

Remove-ProvImageDefinitionScope -ImageDefinitionName $DefinitionName -Scope $Scope
