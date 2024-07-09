# Removing Active Directory (AD) Computer Accounts

This page outlines the base script for removing AD computer accounts on Citrix Virtual Apps and Desktops (CVAD). 



## 1. Base Script: Remove-ADAccount.ps1

`Remove-ADAccount.ps1` is designed to aid in the removal of AD computer accounts. The script requires:

    1. IdentityPoolName: Name of the identity pool from which AD computer accounts will be removed.
    
    2. ADAccountNames: Names of the specific accounts to be removed.
    
    3. RemoveAllAccounts: A flag to indicate whether all AD accounts within the specified identity pool should be removed.
    
    4. AdminAddress: The primary DDC address.
    
The script can be executed with parameters as shown in the examples below:

```powershell
# Remove two AD accounts.
.\Remove-ADAccount.ps1 `
    -IdentityPoolName "MyIdentityPool" `
    -ADAccountNames "MyDomain\MyVM001$","MyDomain\MyVM002$" `
    -AdminAddress "MyDDC.MyDomain.local"

# Remove all AD accounts.
.\Remove-ADAccount.ps1 `
    -IdentityPoolName "MyIdentityPool" `
    -RemoveAllAccounts `
    -AdminAddress "MyDDC.MyDomain.local"
```
Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of removing AD computer accounts is simplified into one key step:

    1. Remove Active Directory (AD) Computer Accounts.



## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for removing AD computer accounts. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.

**Step 1: Remove Active Directory (AD) Computer Accounts.**

The `Remove-AcctADAccount` cmdlet removes AD computer accounts. The parameters for this cmdlet are described below.
    
    1. IdentityPoolName
    The name of the identity pool. This must not contain any of the following characters \/;:#.*?=<>|[]()””’

    2. ADAccountName
    The name of the AD account to be removed. AD accounts are accepted in the following formats: Fully qualified DN e.g. CN=MyComputer,OU=Computers,DC=MyDomain,DC=Com; UPN format e.g MyComputer@MyDomain.Com; Domain qualified e.g MyDomain\MyComputer.

    
## 4. Common Errors During Operation

1. If the identity pool name is invalid, the error message is "Remove-AcctADAccount : Identity Pool not found."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Get-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Get-AcctADAccount.html)
2. [CVAD SDK - Remove-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Remove-AcctADAccount.html)


