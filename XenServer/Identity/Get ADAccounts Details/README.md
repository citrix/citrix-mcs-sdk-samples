# Getting the Detail of AD Accounts within an Identity Pool

This page outlines the base script for getting the detail of AD Accounts within an Identity Pool on Citrix Virtual Apps and Desktops (CVAD). 



## 1. Base Script: Get-ADAccounts-Details.ps1

`Get-ADAccounts-Details.ps1` returns the detail of AD Accounts within an identity pool. The script requires:

    1. IdentityPoolName: Name of the identity pool to be retrieved.
    
The script can be executed with parameters as shown in the example below:

```powershell
.\Get-ADAccounts-Details.ps1 `
    -IdentityPoolName "MyIdentityPool"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of obtaining the detail of AD Accounts within an identity pool is simplified into one key step:

    1. Get the Detail of the AD Accounts.



## 3. Detail of the Base Script

In this section, we explore each step of the base script for obtaining the detail of AD Accounts within an identity pool, outlining key parameters and their roles for a clear understanding of the process.

**Step 1: Get the Detail of the AD Accounts.**

The `Get-AcctADAccount` cmdlet returns the detail of the identity pool. The parameters for this cmdlet are described below.
    
    1. IdentityPoolName
    Specifies the name of the identity pool associated with the AD accounts.


## 4. Common Errors During Operation

1. If the identity pool name is invalid, the error message is not available. Nothing will be returned.



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Get-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Get-AcctADAccount.html)


