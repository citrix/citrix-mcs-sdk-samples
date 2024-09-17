# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

Add-PSSnapin Citrix* -ErrorAction Stop
Import-Module .\vSphereConnect.psm1
Import-Module .\vSphereHelper.psm1
        
        function ConvertVmdkFiles() {
            <#
            .SYNOPSIS
            Converts VMDK file with monolithic-flat format to stream-optimized format
            .DESCRIPTION
             This powershell script  converts the FLAT format disk to stream optimized format for provisioned VM or VM's in a provisioning scheme
            .EXAMPLE
             ConvertVmdkFiles -MCSCatalogName Test -CloudCustomerId 123 -CloudCustomerApiKey 123  -vCenterServerAddress 123 
             ConvertVmdkFiles -VMName Test -CloudCustomerId 123 -CloudCustomerApiKey 123  -vCenterServerAddress 123 
            .PARAMETER ProvisioningSchemeName
                MCS Provisioning Scheme name
            .PARAMETER VMName
             The name of a virtual machine
            .PARAMETER CloudCustomerId
             The customer id
            .PARAMETER CloudCustomerApiKey
             The customer api key
            .PARAMETER vCenterServerAddress
             The vCenter server address
            .PARAMETER ForceRemoveFlatIdentity
             The flag to remove flat identity
            .NOTES
             Version      : 1.0.0
             Author       : Cloud Software Group, Inc.
        #>
       
            param(
                 
                [Parameter(Mandatory = $true, ParameterSetName = 'WithCatalog')]
                [string] $ProvisioningSchemeName,

                [Parameter(Mandatory = $true, ParameterSetName = 'WithVM')]
                [string] $VMName,

                [Parameter(Mandatory = $false)]
                [string] $CloudCustomerId,

                [Parameter(Mandatory = $false)]
                [string] $CloudCustomerApiKey,

                [Parameter(Mandatory = $true)]
                [string] $vCenterServerAddress,

                [Parameter(Mandatory = $false)]
                [bool] $ForceRemoveFlatIdentity = $false
            ) 
            try {

                Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Enter"
                if ( $CloudCustomerId ) {
                    Write-Information "Set-XdCredentials for customer $($CloudCustomerId) for profilename $($CloudCustomerId)" -InformationAction Continue
                    $SecureCloudCustomerApiKeyInput = Read-Host "Please enter your cloud customer secret for $($CloudCustomerApiKey)"  -AsSecureString
                    $EncryptedUserInput = $SecureCloudCustomerApiKeyInput | ConvertFrom-SecureString
                    $SecurePass = ConvertTo-SecureString -String $EncryptedUserInput
                    Set-XDCredentials -CustomerId $cloudCustomerId -ApiKey $CloudCustomerApiKey  -SecretKey $SecurePass  -ProfileType CloudApi -StoreAs $CloudCustomerId -Verbose
                    Write-Information "Get-XdAuthentication for profilename $($CloudCustomerId)" -InformationAction Continue
                    Get-XDAuthentication -ProfileName $CloudCustomerId -Verbose
                }

                $credentials = Get-Credential -Message "Please enter your vCenter credentials for $($vCenterServerAddress)"

                # invoke ConnectToVMware
                ConnectToVMware -ServerAddress $vCenterServerAddress -UserName $credentials.UserName -Password $credentials.Password
               
                # check for  successfully connected to vSphere
                if (!$?) {
					Write-Information -InformationAction Continue "Failed to connect to vSphere"
					return 0
				}
        
                # warn that this operation will power off any machines that are currently running , do you want to continue 
                $prompt = Read-Host "This operation will power off any machines that are currently running. Do you want to continue? (Y/N)"
                if ($prompt -ne "Y" -and $prompt -ne "y") {
					Write-Information -InformationAction Continue "Operation canceled"
					return 0
				}


                if ($PSBoundParameters.ContainsKey('ProvisioningSchemeName')) {
                # read total number of machines from the catalog
                $totalNoOfMachines = Get-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName | Select-Object -ExpandProperty MachineCount
                Write-Information -InformationAction Continue "Total number of machines  : $totalNoOfMachines present in the Provisioning scheme $ProvisioningSchemeName "
                    if($totalNoOfMachines -lt 50) {
						    $provVms = Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName
                            if ($null -eq $provVms) {
                                    Write-Information -InformationAction Continue "Unable to retrieve any provisioned VM's for the specified Provisioning scheme: $ProvisioningSchemeName"
                                    break
                            }
                            # keep count of all soccussfull conversion
                            $successCount = 0
                            foreach ($provVm in $provVms) {

								    Write-Information -InformationAction Continue "Converting FLAT format disk for VM : $provVm.VMName"
								    if(ConvertVmdk -VMName $provVm.VMName -ForceRemoveFlatIdentity $ForceRemoveFlatIdentity)
                                    {
                                        $successCount++
									    Write-Information -InformationAction Continue "FLAT format disk converted successfully for VM : $provVm.VMName"
								    }
								    else
								    {
										Write-Information -InformationAction Continue "Attached identity disk is not converted for VM : $provVm.VMName. Continue with other VM's "    
                                    }
						    }
							Write-Information -InformationAction Continue "Total number of machines  : $successCount converted successfully in the Provisioning scheme $ProvisioningSchemeName "
				    }
                    else {
                            # batch process of size 50 
                            $noOfBatches = [math]::Ceiling($totalNoOfMachines / 50)
                            # loop through the batches
                            for ($i = 0; $i -lt $noOfBatches; $i++) {
							    $start = $i * 50
							    $provVms = Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName -Skip $start -MaxRecordCount 50
                                    if ($null -eq $provVms) {
                                    Write-Information -InformationAction Continue "Unable to retrieve any provisioned VM's for the specified Provisioning scheme: $ProvisioningSchemeName"
                                    break
                                }
                                $successCount = 0
							    foreach ($provVm in $provVms) {
								    Write-Information -InformationAction Continue "Converting FLAT format disk for VM : $provVm of batch $i " 
								    if(ConvertVmdk -VMName $provVm.VMName -ForceRemoveFlatIdentity $ForceRemoveFlatIdentity)
                                    {
                                        $successCount++
									    Write-Information -InformationAction Continue "FLAT format disk converted successfully for VM : $provVm.VMName"
								    }
								    else
								    {
										Write-Information -InformationAction Continue "Attached identity disk is not converted for VM : $provVm.VMName. Continue with other VM's "    
                                    }
							    }
                                Write-Information -InformationAction Continue "Total number of machines  : $successCount converted successfully in the Provisioning scheme $ProvisioningSchemeName of batch $i "
						    }
                    }
                }
                elseif ($PSBoundParameters.ContainsKey('VMName')) {

                    $provVm = Get-ProvVM -VMName $VMName
                    if ($null -eq $provVm) {
                        Write-Information -InformationAction Continue "Unable to retrieve any provisioned VM's for the specified VM: $VMName"
                        break
                    }
                    if(ConvertVmdk -VMName $provVm.VMName -ForceRemoveFlatIdentity $ForceRemoveFlatIdentity)
					{
						Write-Information -InformationAction Continue "FLAT format disk converted successfully for VM : $VMName"
					}
					else
					{
                        Write-Information -InformationAction Continue "Attached identity disk is not converted for VM : $VMName."
					}   
                }
                else {
                    Write-Information -InformationAction Continue "Please provide a valid input"
                }
            }
            finally {
                if ( $CloudCustomerId ) {
                    Write-Information "Clear-XdCredentials for profile name $($CloudCustomerId)" -InformationAction Continue
                    Clear-XDCredentials -ProfileName $CloudCustomerId -Verbose
                }
                #Disconnect from vSphere
                DisconnectFromVMware -ServerAddress $vCenterServerAddress 
                Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Exit"
            }
        }



    # ConvertVmdk function
    function ConvertVmdk() {
        param(
            [Parameter(Mandatory = $true)]
            [string]
            $VMName,
            [Parameter(Mandatory = $false)]
            [bool] $ForceRemoveFlatIdentity = $false
        )
        $psDriveName = 'ds2'
        $fileMgr=Get-View FileManager        
        try {
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Enter"
           
            $result = Get-HardDisk -VM $VMName -DiskType flat  |  Where-Object { $_.FileName -like '*_IdentityDisk.*' -and $_.CapacityGB -le 0.017 }
             
            # check if disk is not null
            if ($null -eq $result) {
				Write-Information -InformationAction Continue "No FLAT format disk found for VM : $VMName"
				 return $false
			}
            $datastoreName = $result.Filename.Split(']')[0].TrimStart('[')
            # check if datastore is not null
            if ($null -eq $datastoreName) {
                Write-Information -InformationAction Continue "No datastore found for VM : $VMName"
                 return $false  
            }
           
            # check if $vSanDatastore is not null
            $vSanDatastore = Get-Datastore -Name $datastoreName | Where-Object { $_.type -match "vsan" }
            if (!$vSanDatastore) {
                Write-Information -InformationAction Continue "No datastore found. Can't continue "
                return $false
            }
            
            # temp folder path from env and append VM name to folder path
            $exportFolderPath = [System.IO.Path]::Combine($env:TEMP, $VMName)
           
            # Download disk in stream optimized format to the temp folder path i:e C:\Users\<user>\AppData\Local\Temp
            $streamOptimizedDiskName = DownloadIdentityDisk -VMName $VMName -ExportFolderPath $exportFolderPath

            if (!$streamOptimizedDiskName) {
                Write-Information -InformationAction Continue "Failed to download disk in stream optimized format. Can't continue "
                return $false
            }
            # Get PS drive 
            if(Get-PSDrive -Name $psDriveName -ErrorAction SilentlyContinue){
                 Write-Information -InformationAction Continue "PS drive $psDriveName is already in use or not exist"
            }
             else 
            {
                Write-Information -InformationAction Continue "Creating PS drive $psDriveName"
				New-PSDrive -Location $vSanDatastore -Name $psDriveName -PSProvider VimDatastore -Root "\" -Scope Global 
			}
            # Upload disk

            $uploadDiskStatus = UploadIdentityDisk  -PSDriveName $psDriveName -VMName $VMName -ExportFolderPath $exportFolderPath
            if (!$uploadDiskStatus) {
                Write-Information -InformationAction Continue "Failed to upload the disk. Can't continue "
                return $false
            }

            # declare variable to check if disk is detached
            [bool] $isDiskDetached = $false
           
            # Detach Identity Disk in FLAT format
            DetachIdentityDiskFromVm  -VMName $VMName -HardDiskName  $result.Filename
           
            # check for any error
            if ($?) {
                Write-Information -InformationAction Continue "Disk $result.Filename detached successfully"
                $isDiskDetached = Get-HardDisk -VM $VMName -DiskType flat | Where-Object { $_.FileName -eq $result.Filename }
            }
            else {
				Write-Information -InformationAction Continue "Failed to detach disk. Can't continue "
				return $false
			}

            # Attach Identity disk in stream optimized format
            $newDiskName = [System.IO.Path]::GetFileName("$streamOptimizedDiskName")
            Write-Information -InformationAction Continue "Attaching disk $newDiskName to VM : $VMName" 
            
            AttachIdentityDiskToVm -VMName $VMName -NewIdentityDiskName $newDiskName  -DatastoreName $vSanDatastore.Name

            # check for any error 
            if ($?) {
				Write-Information -InformationAction Continue "Disk conversion completed successfully"

                if ($ForceRemoveFlatIdentity) {
                    # remove the old disk
                    $oldHardDisk = Get-HardDisk -DatastorePath $result.Filename -Datastore vsanDatastore
                    $fileMgr.DeleteDatastoreFile($oldHardDisk.FileName,$vSanDatastore.Datacenter.ExtensionData.MoRef)
			    }
			}
			else {
                # check if DetachIdentityDiskFromVm was successful and try to attach back the old disk
                if ($isDiskDetached) {
					Write-Information -InformationAction Continue "Failed to attach disk $newDiskName to VM : $VMName. Attaching back the old disk"
					AttachIdentityDiskToVm -VMName $VMName -NewIdentityDiskName $result.Filename  -DatastoreName $vSanDatastore.Name
				}
				Write-Information -InformationAction Continue "Disk conversion failed. Continue with the clean up"
			}
            return $true
        }
        finally {
            # if $streamOptimizedDiskName is not null remove item from $exportFolderPath
            if ($streamOptimizedDiskName) {
                Write-Information -InformationAction Continue "Removing $exportFolderPath"
                Remove-Item -Path $exportFolderPath -Force -Recurse
			}
            # Remove-PSDrive -Name ds2
            if(Get-PSDrive -Name $psDriveName -ErrorAction SilentlyContinue){
				Write-Information -InformationAction Continue "Removing PS drive $psDriveName"
				Remove-PSDrive -Name $psDriveName
			}
            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Exit"
        }
    }

    function RemoveOrphanIdentityDisks {
		 <#
            .SYNOPSIS
             Removes the orphan identity disk post conversion of FLAT format disk to stream optimized format
           
            .DESCRIPTION
             This powershell script  removes the orphan identity disk post conversion of FLAT format disk to stream optimized format for provisioned VM or VM's in a provisioning scheme
            .EXAMPLE
             RemoveOrphanIdentityDisks -MCSCatalogName Test -CloudCustomerId 123 -CloudCustomerApiKey 123  -vCenterServerAddress 123
             RemoveOrphanIdentityDisks -VMName Test -CloudCustomerId 123 -CloudCustomerApiKey 123  -vCenterServerAddress 123
            .PARAMETER ProvisioningSchemeName
                MCS Provisioning Scheme name
            .PARAMETER VMName
             The name of a virtual machine
            .PARAMETER CloudCustomerId
             The customer id
            .PARAMETER CloudCustomerApiKey
             The customer api key
            .PARAMETER vCenterServerAddress
             The vCenter server address
            .NOTES
            Version      : 1.0.0
            Author       : Cloud Software Group, Inc.
            
        #
		#>
		param(
		[Parameter(Mandatory = $true, ParameterSetName = 'WithCatalog')]
        [string] $ProvisioningSchemeName,
        [Parameter(Mandatory = $true, ParameterSetName = 'WithVM')]
        [string] $VMName,
        [Parameter(Mandatory = $false)]
        [string] $CloudCustomerId,

        [Parameter(Mandatory = $false)]
        [string] $CloudCustomerApiKey,

        [Parameter(Mandatory = $true)]
        [string] $vCenterServerAddress

		) 
		try {
			Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Enter"
			if ( $cloudCustomerId ) {
				Write-Information "Set-XdCredentials for customer $($cloudCustomerId) for profilename $($cloudCustomerId)" -InformationAction Continue
                $SecureCloudCustomerApiKeyInput = Read-Host "Please enter your cloud customer secret for $($CloudCustomerApiKey)"  -AsSecureString
                $EncryptedUserInput = $SecureCloudCustomerApiKeyInput | ConvertFrom-SecureString
                $SecurePass = ConvertTo-SecureString -String $EncryptedUserInput
				Set-XDCredentials -CustomerId $cloudCustomerId -ApiKey $cloudCustomerApiKey  -SecretKey $SecurePass  -ProfileType CloudApi -StoreAs $cloudCustomerId -Verbose
				Write-Information "Get-XdAuthentication for profilename $($cloudCustomerId)" -InformationAction Continue
				Get-XDAuthentication -ProfileName $cloudCustomerId -Verbose
			}


            $credentials = Get-Credential -Message "Please enter your vCenter credentials"
            # invoke ConnectToVMware
            ConnectToVMware -ServerAddress $vCenterServerAddress -UserName $credentials.UserName -Password $credentials.Password
            $fileMgr=Get-View FileManager   
            # Verify successful connection to vSphere.
            if (!$?) {
			    Write-Information -InformationAction Continue "Failed to connect to vSphere"
			    return 0
		    }
			if ($PSBoundParameters.ContainsKey('ProvisioningSchemeName')) {
				## Max count  is 50 
				$provVms = Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName
				if ($null -eq $provVms) {
					Write-Information -InformationAction Continue "Unable to retrieve any provisioned VM's for the specified catalog: $ProvisioningSchemeName"
					break
				}
                foreach ($provVm in $provVms) {
                    Write-Information -InformationAction Continue "Removing orphan identity disk for VM : $provVm"
                    RemoveDiskFromDatastore -VMName $provVm.VMName -FileMgr $fileMgr
				}
            }
            elseif ($PSBoundParameters.ContainsKey('VMName')) {
				$provVm = Get-ProvVM -VMName $VMName
				if ($null -eq $provVm) {
					Write-Information -InformationAction Continue "Unable to retrieve any provisioned VM's for the specified VM: $VMName"
					break
				}
				Write-Information -InformationAction Continue "Removing orphan identity disk for VM : $provVm"
                RemoveDiskFromDatastore -VMName $provVm.VMName -FileMgr $fileMgr
			}
			else {
				Write-Information -InformationAction Continue "Please provide a valid input"
			}
        }
        finally {
			if ( $CloudCustomerId ) {
                    Write-Information "Clear-XdCredentials for profilename $($CloudCustomerId)" -InformationAction Continue
                    Clear-XDCredentials -ProfileName $CloudCustomerId -Verbose
                }
                #Disconnect from vSphere
                DisconnectFromVMware -ServerAddress $vCenterServerAddress 
                Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Exit"
		}
    }

    function RemoveDiskFromDatastore {
        param(
            [Parameter(Mandatory = $true)]
            [string]
            $VMName,
            [Parameter(Mandatory = $true)]
            [PSObject]
            $FileMgr
            
        )
        Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Enter"
        $result = Get-HardDisk -VM $VMName |  Where-Object { $_.FileName -like '*_IdentityDisk-1.*' }
        $datastoreName = $result.Filename.Split(']')[0].TrimStart('[')
        $vSanDatastore = Get-Datastore -Name $datastoreName | Where-Object { $_.type -match "vsan" }
        if (!$vSanDatastore) {
                Write-Information -InformationAction Continue "No datastore found. Can't continue "
                return $false
        }
        $vmDiskPath = "[" +  $vSanDatastore + "] " + $VMName
		$oldHardDisk = Get-HardDisk  -DiskType flat -Datastore $vSanDatastore -DatastorePath $vmDiskPath |  Where-Object {$_.FileName -like '*_IdentityDisk.vmdk' -and $_.CapacityGB -le 0.017}
        # check if hard disk is not null
        if ($null -eq $oldHardDisk) {
            Write-Information -InformationAction Stop "Hard disk not found that ends with _IdentityDisk.vmdk"
            break
        }
        $FileMgr.DeleteDatastoreFile($oldHardDisk.FileName,$vSanDatastore.Datacenter.ExtensionData.MoRef)
        Write-Information -InformationAction Continue "Successfully removed old identity disk for VM : $VMName"
        Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Exit"
    }


    function RollBackIdentityDiskConversion{
        		<#  
                .SYNOPSIS
                Rolls back the conversion of the identity disks from a stream-optimized VMDK format to a monolithic-flat
                .DESCRIPTION
                This function is used to rollback the conversion of the identity disks from a stream-optimized VMDK format to a monolithic-flat.It assumes that the original identity disk is still present in the VM folder.
                .PARAMETER VMName
					The name of a virtual machine
                    .PARAMETER CloudCustomerId
                    The customer id
                    .PARAMETER CloudCustomerApiKey
                    The customer api key
                    .PARAMETER vCenterServerAddress
                    The vCenter server address
                    .EXAMPLE
                    RollBackIdentityDiskConversion -VMName Test -CloudCustomerId 123 -CloudCustomerApiKey 123 -vCenterServerAddress 123
                    #>  

                    param(
						[Parameter(Mandatory = $true, ParameterSetName = 'WithCatalog')]
                        [string] $ProvisioningSchemeName,
                        [Parameter(Mandatory = $true, ParameterSetName = 'WithVM')]
                        [string] $VMName,
						[Parameter(Mandatory = $false)]
						[string] $CloudCustomerId,
						[Parameter(Mandatory = $false)]
						[string] $CloudCustomerApiKey,
						[Parameter(Mandatory = $true)]
						[string] $vCenterServerAddress
					)

                try {
			            Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Enter"

			            if ( $cloudCustomerId ) {
				            Write-Information "Set-XdCredentials for customer $($cloudCustomerId) for profilename $($cloudCustomerId)" -InformationAction Continue
                            $SecureCloudCustomerApiKeyInput = Read-Host "Please enter your cloud customer secret for $($CloudCustomerApiKey)"  -AsSecureString
                            $EncryptedUserInput = $SecureCloudCustomerApiKeyInput | ConvertFrom-SecureString
                            $SecurePass = ConvertTo-SecureString -String $EncryptedUserInput
				            Set-XDCredentials -CustomerId $cloudCustomerId -ApiKey $cloudCustomerApiKey  -SecretKey $SecurePass  -ProfileType CloudApi -StoreAs $cloudCustomerId -Verbose
				            Write-Information "Get-XdAuthentication for profilename $($cloudCustomerId)" -InformationAction Continue
				            Get-XDAuthentication -ProfileName $cloudCustomerId -Verbose
			            }

                        $credentials = Get-Credential -Message "Please enter your vCenter credentials"
                         # invoke ConnectToVMware
                        ConnectToVMware -ServerAddress $vCenterServerAddress -UserName $credentials.UserName -Password $credentials.Password
               
                        # Verify successful connection to vSphere.
                        if (!$?) {
					        Write-Information -InformationAction Continue "Failed to connect to vSphere"
					        return 0
				        }

                        if ($PSBoundParameters.ContainsKey('ProvisioningSchemeName')) {
                            $provVms = Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName
                            if ($null -eq $provVms) {
					        Write-Information -InformationAction Continue "Unable to retrieve any provisioned VM's for the specified catalog: $ProvisioningSchemeName"
					        break
				            }

                        }
                        elseif ($PSBoundParameters.ContainsKey('VMName')) {
				            $provVm = Get-ProvVM -VMName $VMName
				            if ($null -eq $provVm) {
					            Write-Information -InformationAction Continue "Unable to retrieve any provisioned VM's for the specified VM: $VMName"
					            break
				            }
				            Write-Information -InformationAction Continue "Reverting converted identity disk for VM : $provVm"
                            # detach identity disk that was attached during the migration process.
                            $result = Get-HardDisk -VM $VMName  |  Where-Object { $_.FileName -like '*_IdentityDisk-1.*' -and $_.CapacityGB -le 0.017 }
                            if ($null -eq $result) {
								Write-Information -InformationAction Continue "there is no disk found for VM : $VMName converted during migration"
								break
							}
                        
                            $datastoreName = $result.Filename.Split(']')[0].TrimStart('[')
                            # check if datastore is not null
                            if ($null -eq $datastoreName) {
                                Write-Information -InformationAction Continue "No datastore found for VM : $VMName"
                                 return $false  
                            }
           
                            # check if $vSanDatastore is not null
                            $vSanDatastore = Get-Datastore -Name $datastoreName | Where-Object { $_.type -match "vsan" }
                            if (!$vSanDatastore) {
                                Write-Information -InformationAction Continue "No datastore found. Can't continue "
                                return $false
                            }

                            DetachIdentityDiskFromVm  -VMName $VMName -HardDiskName  $result.Filename
                            # check for any error
                            if ($?) {
								Write-Information -InformationAction Continue "Disk $result.Filename detached successfully"
							}
							else {
								Write-Information -InformationAction Continue "Failed to detach disk. Can't continue "
								return $false
							}

                            # The disk name comprises a combination of the virtual machine's name and a string identifying the disk.
                            $identityDiskName = $VMName + "_IdentityDisk.vmdk"
                            # attach the old identity disk
                             AttachIdentityDiskToVm -VMName $VMName -NewIdentityDiskName $identityDiskName  -DatastoreName $vSanDatastore.Name
				            
			            }
			            else {
				            Write-Information -InformationAction Continue "Please provide a valid input"
			            }

                }

                finally {
			        if ( $CloudCustomerId ) {
                        Write-Information "Clear-XdCredentials for profilename $($CloudCustomerId)" -InformationAction Continue
                        Clear-XDCredentials -ProfileName $CloudCustomerId -Verbose
                    }
                    #Disconnect from vSphere
                    DisconnectFromVMware -ServerAddress $vCenterServerAddress 
                    Write-Information -InformationAction Continue "$($MyInvocation.InvocationName) - Exit"
		        }
    }
