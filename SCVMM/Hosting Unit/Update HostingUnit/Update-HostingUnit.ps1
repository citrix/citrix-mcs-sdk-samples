<#
.SYNOPSIS
    Update the HostingUnit.
.DESCRIPTION
    Update-HostingUnit.ps1 contains the commands for renaming the HostingUnit, modifying the storage of hosting unit, modifying the metadata of a hosting unit.

    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$HostingUnitName ="HostingUnitName"
$RenameHostingUnitName = "RenameHostingUnitName"

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$HostingUnitPath = "XDHyp:\HostingUnits\" + $HostingUnitName
$NewStoragePath = $HostingUnitPath + "\new-storage.storage"

$HostingUnit = Get-Item -Path $HostingUnitPath
if($null -eq $HostingUnit)
{
    throw "Provided HostingUnitName is not valid. Please give the right HostingUnitName"
}

#########################################
# To rename the HostingUnit #
#########################################

if($RenameHostingUnitName -ne "")
{
    Rename-Item -NewName $RenameHostingUnitName -Path $HostingUnitPath
}

#########################################
# To modify the HostingUnit's storage #
#########################################
Set-HypHostingUnitStorage -LiteralPath $HostingUnitPath -StoragePath $NewStoragePath
#Cannot be used if the hosting connection for this hosting unit is in maintainenence mode.


#########################################
# To modify the HostingUnit's metadata #
#########################################
Set-HypHostingUnitMetadata -HostingUnitUid "demo-hostingunit-uid" -Name "Metadatakey1" -Value "Metadatavalue1"