# Adding Active Directory (AD) Computer Accounts

This page outlines the base script for adding AD computer accounts on Citrix Virtual Apps and Desktops. 



## 1. Base Script: Add-ADAccount.ps1

The `Add-ADAccount.ps1` script facilitates the addition of AD computer accounts. It requires the following parameters:

    1. IdentityPoolName: The name of the identity pool to add AD computer accounts.
    
    2. Count: The number of accounts to be added.
    
    3. AdminAddress: The primary DDC address.
    
The script can be executed with parameters as shown in the example below:

```powershell
.\Add-ADAccount.ps1 `
    -IdentityPoolName "MyIdentityPool" `
    -Count 2 `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of adding AD computer accounts is simplified into one key step:

    1. Add Active Directory (AD) Computer Accounts.



## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for adding AD computer accounts. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.

**Step 1: Create a New Identity Pool.**

The `New-AcctADAccount` cmdlet creates new AD computer accounts. The parameters for this cmdlet are described below.
    
    1. IdentityPoolName
    The name of the identity pool. This must not contain any of the following characters \/;:#.*?=<>|[]()””’

    2. Count
    The number of accounts to create.
    

## 4. Common Errors During Operation

1. If the identity pool name is invalid, the error message is "New-AcctADAccount : Object reference not set to an instance of an object."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - New-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/New-AcctADAccount.html)


