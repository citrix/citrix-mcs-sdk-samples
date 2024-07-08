### Create ProvScheme and Catalog
```New-ProvScheme``` cmdlet is used to create a provisioning scheme. You can learn more about New-ProvScheme cmdlet [here](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2311/MachineCreation/New-ProvScheme.html).
Following example shows parameters required to create a provisioning scheme:
```powershell
New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
    -ProvisioningSchemeName $provisioningSchemeName `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MasterImageVM $masterImagePath `
    -NetworkMapping $networkMapping `
```

Creating a provisioning scheme alone does not make it visible in the Studio. You need to create a broker catalog to view and manage it from the Studio. You can learn more about New-BrokerCatalog cmdlet [here](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2311/Broker/New-BrokerCatalog.html).
Following example shows parameters required to create a broker catalog:
```powershell
New-BrokerCatalog -Name $ProvisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $allocationType  `
    -Description $description `
    -IsRemotePC $False `
    -PersistUserChanges $persistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $sessionSupport
```

Example script Create-Catalog.ps1 in this folder shows how to use these cmdlets to create a provisioning scheme and a Broker catalog. Please be aware that New-ProvScheme is a long running operation and it may take awhile to complete.