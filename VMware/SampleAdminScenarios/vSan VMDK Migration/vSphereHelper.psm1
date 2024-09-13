## Description: This file contains the PowerShell module for vSphereHelper
    function PowerOnVM() {
        <#
        .SYNOPSIS
         Power on operation for a machine.
        .DESCRIPTION
         This function powers on a virtual machine
        .PARAMETER VMName
            The name of a virtual machine
        .EXAMPLE
            PowerOnVM -VMName Test
        #>
        # /*************************************************************************
        # * Copyright © 2024. Cloud Software Group, Inc.
        # * This file is subject to the license terms contained
        # * in the license file that is distributed with this file.
        # *************************************************************************/
        param(
            [Parameter(Mandatory = $true)]
            [string]
            $VMName
        )
        try {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Enter"
            $vm = Get-VM -Name $VMName
            $power_state = $vm.PowerState
            Write-Information -InformationAction Continue "Current power state:: $power_state"
            if ($power_state -eq "PoweredOff") {
                Write-Information -InformationAction Continue "Powering on now VM: $VMName"
                Start-VM -Name $VMName -RunAsync 
            }
        }
        finally {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Exit"
        }
    }



    function PowerOffVM() {
        <#
        .SYNOPSIS
        Power off operation for a machine.
        .DESCRIPTION
            This function powered off a virtual machine
        .PARAMETER VMName
            The name of a virtual machine
        .EXAMPLE
            PowerOffVM -VMName Test
        #>
        # /*************************************************************************
        # * Copyright © 2024. Cloud Software Group, Inc.
        # * This file is subject to the license terms contained
        # * in the license file that is distributed with this file.
        # *************************************************************************/
        param(
            [Parameter(Mandatory = $true)]
            [string]
            $VMName
        )
        try {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Enter"
            # Pull VM from vSphere, 
            $vm = Get-VM -Name $VMName
            $power_state = $vm.PowerState
            Write-Information -InformationAction Continue "Current power state:: $power_state"
            if ($power_state -eq "PoweredOn") {
                Write-Information -InformationAction Continue "Powering off now VM: $VMName"
                Stop-VM -VM $vm -RunAsync -Confirm:$false
            }
        }
        finally {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Exit"
        }
    }

    function DownloadIdentityDisk() {
        <#
        .SYNOPSIS
         Download the disk from datastore in stream format.
        .DESCRIPTION
            This function exports disks created in FLAT format of a virtual machine from vCenter
        .PARAMETER VMName
            The name of a virtual machine
        .PARAMETER ExportFolderPath
            The path of the folder for downloading the disk file
        .EXAMPLE
            DownloadIdentityDisk -VMName Test -ExportFolderPath "C:\Folder"
        #>
        # /*************************************************************************
        # * Copyright © 2024. Cloud Software Group, Inc.
        # * This file is subject to the license terms contained
        # * in the license file that is distributed with this file.
        # *************************************************************************/
        param(
            [Parameter(Mandatory = $true)]
            [string]
            $VMName,
            [Parameter(Mandatory = $true)]
            [string]
            $ExportFolderPath
        ) 
        try {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Enter"
            #$ExportFolderPath += $VMName + '\'
            # Check and create the folder if not exists
            if (!(test-path -path $ExportFolderPath)) {
                new-item -path $ExportFolderPath -itemtype directory
            }
            $ExportFolderPath= [System.IO.Path]::Combine($ExportFolderPath + '\')
            Write-Information -InformationAction Continue "Downloading disk to $ExportFolderPath"
            $vm = Get-VM -Name $VMName
            $power_state = $vm.PowerState
            if ($power_state -ne "PoweredOff") {
                Write-Information -InformationAction Continue "Export VM is only supported on a powered off VM: $VMName"
                ## invoke power off call
                PowerOffVM -VMName $VMName
                ## wait for the VM to power off before proceeding else poll until 60 seconds and exit
                $timer = 0        
                 while ($vm.PowerState -ne "PoweredOff") {
					if ($timer -eq 60) {
						Write-Information -InformationAction Continue "VM: $VMName did not power off in 60 seconds"
						break
					}
                    $timer=$timer+5
					start-sleep 5
                    $vm = Get-VM -Name $VMName
				}
            }
            $flatIdentityDiskInfo = (Get-HardDisk -VM $VMName -DiskType flat |  Where-Object { $_.FileName -like '*_IdentityDisk.*' -and $_.CapacityGB -le 0.017 })
            if ($null -eq $flatIdentityDiskInfo) {
                Write-Information -InformationAction Continue "Unable to locate the identity disk created in flat format for VM: $VMName"
                break
            }
            $unitNumber = $flatIdentityDiskInfo.ExtensionData.UnitNumber
            $diskIdentifierInUrl = 'disk-' + $unitNumber
            $lease = Get-View -Id ($vm.ExtensionData.ExportVm())

            while ($lease.State -eq [VMware.Vim.HttpNfcLeaseState]::initializing) {
                start-sleep 1
                $lease.UpdateViewData('State')
            }
            $lease.UpdateViewData()
            if ($lease.State -eq [VMware.Vim.HttpNfcLeaseState]::ready) {
                Write-Information -InformationAction Continue "Lease timeout $($lease.Info.LeaseTimeout)"
                $bufferSize = 10KB
                $bytesWritten = 0

                foreach ($device in ($lease.Info.DeviceUrl | Where-Object { $_.Disk -and $_.Url.Contains($diskIdentifierInUrl) })) {

                    # URL escaping may be needed  
                    Write-Information -InformationAction Continue "Transferring $($device.Url.Split('/')[-1])"
                    $diskFile = "$($ExportFolderPath)$($VMName)_Identity$($device.Url.Split('/')[-1])"
                    $url = $device.Url.Replace('*', $vm.VMHost.Name)
                    $webRequest = [System.Net.WebRequest]::Create($url)
                    $response = $webRequest.GetResponse()
                    $responseStream = $response.GetResponseStream()
                    $fileStream = [System.IO.File]::OpenWrite($diskFile)
                    $chunk = New-Object byte[] $bufferSize
                    while (($bytesRead = $responseStream.Read($chunk, 0, $bufferSize))) {
                        $totalBytesRead += $bytesRead
                        $fileStream.Write($chunk, 0, $bytesRead)
                        $fileStream.Flush()
                    }
                    $bytesWritten += $fileStream.Length
                    $FileStream.Close()
                    $responseStream.Close()
                    $lease.HttpNfcLeaseProgress([int]($bytesWritten / ($lease.Info.TotalDiskCapacityInKB * 1KB) * 100))
                    Write-Information -InformationAction Continue "Bytes written $($bytesWritten)"
                }
                $lease.HttpNfcLeaseProgress(100)
                $lease.HttpNfcLeaseComplete()
                Write-Information -InformationAction Continue "Export complete"
            }
        }
        finally {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Exit"
        }
        return $diskFile
    }

    # This function is used to upload the identity disk to the VM
    function UploadIdentityDisk() {
        param(
            [Parameter(Mandatory = $true)]
            [string]
            $PSDriveName,
            [Parameter(Mandatory = $true)]
            [string]
            $VMName,
            [Parameter(Mandatory = $true)]
            [string]
            $ExportFolderPath
        ) 
        try {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Enter"

            # check if PS drive exists before copying the file
            Get-PSDrive -Name $PSDriveName -ErrorAction Stop

            # Check file exists under VM folder 
            if (!(Test-Path -Path $ExportFolderPath)) {
				Write-Information -InformationAction Stop "File not found in the path: $ExportFolderPath"
				return 0
			}
            # combine the destination path
            $destinationVmPath = [System.IO.Path]::Combine($PSDriveName + ':\' + $VMName + '\')

            $ExportFolderPath= [System.IO.Path]::Combine($ExportFolderPath + '\*') 
            Write-Information -InformationAction Continue "Uploading the disk from- $ExportFolderPath to - $destinationVmPath"
            Copy-DatastoreItem -Item $ExportFolderPath  -Destination  $destinationVmPath 
        }
        finally {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Exit"
        }
    }


    # This function is used to Detach the identity disk from the VM
    function DetachIdentityDiskFromVm() {
         <#
        .SYNOPSIS
         Detach disk from a virtual machine
        .DESCRIPTION
			This function detach the identity disk from the virtual machine
            .PARAMETER VMName
			The name of a virtual machine
            .PARAMETER HardDiskName
            The name of the hard disk
            .EXAMPLE
            DetachIdentityDiskFromVm -VMName Test -HardDiskName Test.vmdk
        #>
        # /*************************************************************************
        # * Copyright © 2024. Cloud Software Group, Inc.
        # * This file is subject to the license terms contained
        # * in the license file that is distributed with this file.
        # *************************************************************************/

        param(
            [Parameter(Mandatory = $true)]
            [string]
            $VMName,
            [Parameter(Mandatory = $true)]
            [string]
            $HardDiskName
        )
        try {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Enter"
            # detach disk from the vmware VM
            $vm = Get-VM -Name $VMName
            # check if VM is not null 
            if ($null -eq $vm) {
				Write-Information -InformationAction Continue "VM not found: $VMName"
				break
			}
            $hardDisk = Get-HardDisk -VM $VMName | Where-Object { $_.FileName -eq $HardDiskName }
            # check if hard disk is not null
            if ($null -eq $hardDisk) {
                Write-Information -InformationAction Stop "Hard disk not found: $HardDiskName"
                break
            }
            Write-Information -InformationAction Continue "Detaching disk: $HardDiskName from VM: $VMName"
            Remove-HardDisk -HardDisk $hardDisk -DeletePermanently:$false -Confirm:$false
        }
        finally {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Exit"
        }
    }

    # This function is used to Attach the identity disk to the VM
    function AttachIdentityDiskToVm() {
        <#
            .SYNOPSIS
            Attach disk to a virtual machine
            .DESCRIPTION
            This function attach the identity disk to the virtual machine
		    .PARAMETER VMName
            The name of a virtual machine
            .PARAMETER NewIdentityDiskName
            The name of the new identity disk
                
            .PARAMETER DatastoreName
            The name of the datastore
            .EXAMPLE
            AttachIdentityDiskToVm -VMName Test -NewIdentityDiskName Test.vmdk -DatastoreName TestDatastore
        #>
        # /*************************************************************************
        # * Copyright © 2024. Cloud Software Group, Inc.
        # * This file is subject to the license terms contained
        # * in the license file that is distributed with this file.
        # *************************************************************************/
        param(
            [Parameter(Mandatory = $true)]
            [string]
            $VMName,
            [Parameter(Mandatory = $true)]
            [string]
            $NewIdentityDiskName,
            [Parameter(Mandatory = $true)]
            [string]
            $DatastoreName
        ) 
        try {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Enter"
            $vm = Get-VM -Name $VMName
             # check if VM is not null 
            if ($null -eq $vm) {
				Write-Information -InformationAction Continue "VM not found: $VMName"
				break
			}
            Write-Information -InformationAction Continue "New Identity disk name: $NewIdentityDiskName"

            # Construct disk name by using $DatastoreName, $VMName and $NewIdentityDiskName
            $identityDiskName = "[" + $DatastoreName + "] " + $VMName + "/" + $NewIdentityDiskName
            # print the disk name
            Write-Information -InformationAction Continue "Identity disk name: $identityDiskName"
            # attach hard disk to the vmware VM
            New-HardDisk -VM $vm -DiskPath $identityDiskName  
        }
        catch 
        {
		    Write-Information -InformationAction Continue "Error: $_"   
        }
        finally {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Exit"
        }
    }

    # This function is used to check if the identity disk is created in flat format
    function CheckVmdkCreatedWithFlat() {
        param(
            [Parameter(Mandatory = $true)]
            [string]
            $VMName
        ) 
        try {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Enter"
            $result = Get-HardDisk -VM $VMName -DiskType flat  |  Where-Object { $_.FileName -like '*_IdentityDisk.*' -and $_.CapacityGB -le 0.017 }
            # check if result is not null
            if ($null -eq $result) {
				Write-Information -InformationAction Continue "Identity disk created in flat format not found for VM: $VMName"
				return $false
			}
            if ($result) {
                $datastoreName = $result.Filename.Split(']')[0].TrimStart('[')
                $datastoreName = Get-Datastore -Name $datastoreName | Where-Object { $_.type -match "vsan" }
            }
            return $datastoreName  | Out-Null
        }
        finally {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Exit"
        }
    }

    