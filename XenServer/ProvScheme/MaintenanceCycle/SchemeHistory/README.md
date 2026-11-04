# Scheme History

Retrieves the provisioning scheme history. Shared across ImageUpdate and HardwareSchemeUpdate operation types.

**Optional filter parameters:**
- `ProvisioningSchemeName`
- `ProvisioningSchemeUid`
- `ImageVersionSpecUid`
- `ProvisioningSchemeHistoryVersion`

```powershell
Get-ProvSchemeHistory -ProvisioningSchemeName $provisioningSchemeName -ProvisioningSchemeHistoryVersion 1
```

See [Get-SchemeHistory.ps1](./Get-SchemeHistory.ps1)
