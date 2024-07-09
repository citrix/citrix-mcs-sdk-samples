# Removing an Identity Pool

This page outlines the base script for deleting an identity pool on Citrix Virtual Apps and Desktops. 



## 1. Base Script: Remove-IdentityPool.ps1

`Remove-IdentityPool.ps1` is designed to aid in the deletion of an identity pool. The script requires:

    1. IdentityPoolName: Name of the identity pool to be removed.

    2. AdminAddress: The primary DDC address.
    
The script can be executed with parameters as shown in the example below:

```powershell
.\Remove-IdentityPool.ps1 `
    -IdentityPoolName "MyIdentityPool" `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of deleting an identity pool is simplified into one key step:

    1. Remove the Identity Pool.



## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for deleting an identity pool. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.

**Step 1: Delete the Identity Pool.**

The `Remove-AcctIdentityPool` cmdlet deletes an identity pool. The parameters for this cmdlet are described below.
    
    1. IdentityPoolName
    The name of the identity pool to be deleted. This must not contain any of the following characters \/;:#.*?=<>|[]()””’


## 4. Common Errors During Operation

1. If the identity pool name is invalid, the error message is "Remove-AcctIdentityPool : Identity Pool not found."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Get-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Get-AcctADAccount.html)
2. [CVAD SDK - Remove-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Remove-AcctIdentityPool.html)


