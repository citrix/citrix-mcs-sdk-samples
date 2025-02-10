function Get-UnmanagedDiskCount {
    param(
        [Parameter(Mandatory = $true)]
        [PSObject]$azVm
    )

    if ($azVm -eq $null) {
        Write-Warning "The provided azVm object is null. Skipping..."
        return 0
    }

    $unmanagedDataDisks = $azVm.StorageProfile.DataDisks | Where-Object { $null -eq $_.ManagedDisk  }
    $unmanagedOsDisk = $null -eq $azVm.StorageProfile.OsDisk.ManagedDisk

    $totalUnmanagedDisks = $unmanagedDataDisks.Count
    if ($unmanagedOsDisk) {
        $totalUnmanagedDisks += 1
    }

    return $totalUnmanagedDisks
}

function Get-AzVmByResourceGroupAndName {
    param(
        [string]$resourceGroupName,
        [string]$vmName
    )

    $azVm = $null
    try {
        $azVm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -ErrorAction Stop
    }
    catch {
        Write-Warning "VM '$vmName' in resource group '$resourceGroupName' was not found or is deleted. Skipping..."
        return $null
    }

    return $azVm
}

$brokerMachines = Get-BrokerMachine | Select-Object CatalogName, HostedMachineId, MachineName
$results = @()

foreach ($machine in $brokerMachines) {
    $recommendation = ""
    $vmType = ""
    $vhdCount = ""

    $splitId = $machine.HostedMachineId -split "/"
    $splitDomain = $machine.MachineName -split "\\"

    # Handle invalid machine name format
    if ($splitDomain.Length -ne 2) {
        Write-Warning "Machine name '$($machine.MachineName)' is not in the expected format. Skipping..."
        continue
    }

    if ($splitId.Length -ne 2) {
        Write-Warning "HostedMachineId '$($machine.HostedMachineId)' is not in the expected format. Skipping..."
        continue
    }

    $resourceGroupName, $vmName = $splitId[0], $splitId[1]
    $domain, $computerName = $splitDomain[0], $splitDomain[1]

    try {
        $provVm = Get-ProvVm -VmName $vmName
    }
    catch {
        Write-Warning "Failed to retrieve information for VM '$vmName'. Skipping..."
        continue
    }

    if ($null -ne $provVm) {
        $customVmData = $provVm.CustomVmData | ConvertFrom-Json

        # Skip VM if it is using managed disks
        if ($customVmData -and $customVmData.PSObject.Properties['IsUsingManagedDisks'] -and $customVmData.IsUsingManagedDisks) {
            continue
        }

        if ($provVm.CleanOnBoot -eq $true) {
            $vmType = "Non-Persistent"
            $recommendation = "Please delete any VMs in this machine catalog and provision a new machine catalog with managed disks."
        } else {
            $azVm = Get-AzVmByResourceGroupAndName -resourceGroupName $resourceGroupName -vmName $vmName
            if (-not $azVm) {
                continue
            }

            $vmType = "Power-managed only"
            $recommendation = "Please convert to Managed disks on the Azure portal."

            $vhdCount = Get-UnmanagedDiskCount -azVm $azVm
            if ($vhdCount -eq 0) {
                continue
            }

            $vmType = "Persistent"
            $recommendation = "Please export VMs in this catalog, convert to Managed disks on the Azure portal and import these VMs as Power-managed VMs."
        }

        $results += [PSCustomObject]@{
            CatalogName      = $machine.CatalogName
            ResourceGroup    = $resourceGroupName
            VMName           = $vmName
            AzureVmId        = $azVm.Id
            VhdCount         = $vhdCount
            VMType           = $vmType
            Domain           = $domain
            ComputerName     = $computerName
            Recommendation   = $recommendation
        }
    } else {
        # Handle Power-managed VM case
        $azVm = Get-AzVmByResourceGroupAndName -resourceGroupName $resourceGroupName -vmName $vmName
        if (-not $azVm) {
            continue
        }

        $vmType = "Power-managed only"
        $recommendation = "Please convert to Managed disks on the Azure portal."

        $vhdCount = Get-UnmanagedDiskCount -azVm $azVm
        if ($vhdCount -eq 0) {
            continue
        }

        $results += [PSCustomObject]@{
            CatalogName      = $machine.CatalogName
            ResourceGroup    = $resourceGroupName
            VMName           = $vmName
            AzureVmId        = $azVm.Id
            VhdCount         = $vhdCount
            VMType           = $vmType
            Domain           = $domain
            ComputerName     = $computerName
            Recommendation   = $recommendation
        }
    }
}

# Output the results
if ($results.Count -gt 0) {
	Write-Output "Found '$($results.Count)' VMs with unmanaged disks."

	$resultsForDisplay = $results | Select-Object CatalogName, ResourceGroup, VMName, VhdCount, Domain, Recommendation

	$resultsForDisplay | Format-Table -AutoSize

	$csvPath = ".\AzVmWithUnmanagedDisks.csv"
	$results | Export-Csv -Path $csvPath -NoTypeInformation

    # Inform the admin with a formal message
    Write-Output "The results have been exported to '$csvPath'."
} else {
    Write-Output "No virtual machines with unmanaged disks were found. No export to CSV was performed."
}
