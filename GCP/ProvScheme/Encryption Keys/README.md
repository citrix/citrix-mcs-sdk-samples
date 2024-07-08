# Encryption Keys
## Overview
Using MCS Provisioning, you can provision machines encrypted with Customer Managed Encryption Keys (CMEK) in GCP environments. To learn more about GCP CMEKs, please refer to the [GCP documentation](https://cloud.google.com/kms/docs/cmek).

With MCS, you can specify regional, global or shared CMEKs for the Machine Catalog. This enables you to comply with organizational policies like use of encryption keys for data at rest or using CMEKs from shared project.

# Prerequisites for using CMEKs with MCS Provisioning
Ensure permissions to use CMEKs (crypto keys and key rings) are in place. Please refer to [Permissions required documentation](https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-gcp.html#project-level-kms-permissions).
Ensure that the crypto key is discoverable by the inventory service. You can use the following command to list the crypto keys and key rings available to current hosting unit:
```powershell
Get-Contents -path "XDHyp:\HostingUnits\my-hosting-unit\encryptionKeys.folder"
```

An example of how to create a catalog using the New-ProvScheme cmdlet with CMEK is provided in the script Create-Catalog-With-EncryptionKeys.ps1. 
An example of how to set/update the encryption using Set-ProvScheme cmdlet is provided in the script Set-EncryptionKey.ps1. Encryption keys cannot be changed for existing machines in the catalog. It applies to new machines created in the catalog.

## Errors users may encounter during Create/Update Catalog operation
* If the crypto key or key ring is invalid, the error message would look like - "Invalid CryptoKeyId specified in ProvScheme CustomSettings. Error occurred while validating crypto key 'project-id:region:my-regional-ring:my-regional-ring'".