# Creating an Identity Pool

This page outlines the base script for creating a Domain-Joined Identity Pool on Citrix Virtual Apps and Desktops (CVAD).



## 1. Base Script: Add-IdentityPool.ps1

The `Add-IdentityPool.ps1` script facilitates the creation of an Identity Pool. It requires the following parameters:

    1. IdentityPoolName: The name of the identity pool.
    
    2. ZoneUid: The UID that corresponds to the Zone in which these AD accounts will be created.   

    3. AdminAddress: The primary DDC address.
    
    4. NamingScheme: Defines the template name for AD accounts created in the identity pool.
    
    5. NamingSchemeType: The type of naming scheme. This can be Numeric or Alphabetic.
    
    6. Scope: The administration scopes to be applied to the new identity pool.

    7. WorkGroupMachine: Indicates whether the accounts created should be part of a workgroup rather than a domain.
    
    8. Domain: The AD domain name for the pool. Specify this in FQDN format; for example, MyDomain.local.


Additionally, the script supports these optional parameters:

    8. WorkGroupMachine: Indicates whether the accounts created should be part of a workgroup rather than a domain.
    
    9. Domain: The AD domain name for the pool. Specify this in FQDN format; for example, MyDomain.com.


The script can be executed with parameters as shown in the example below:

```powershell
# Create a Domain-Joined IdentityPool
.\Add-IdentityPool.ps1 `
    -IdentityPoolName "MyIdentityPool" `
    -ZoneUid "00000000-0000-0000-0000-000000000000" `
    -AdminAddress "MyDDC.MyDomain.local" `
    -Domain "MyDomain.local" `
    -NamingScheme "MyVM###" `
    -NamingSchemeType "Numeric" `
    -Scope @()

# Create a Non-Domain-Joined IdentityPool
.\Add-IdentityPool.ps1 `
    -IdentityPoolName "MyIdentityPool" `
    -ZoneUid "00000000-0000-0000-0000-000000000000" `
    -AdminAddress "MyDDC.MyDomain.local" `
    -WorkGroupMachine `
    -NamingScheme "MyVM###" `
    -NaingSchemeType "Numeric" `
    -Scope @()
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of creating of a Domain-Joined Identity Pool is simplified into one key step:

    1. Create a New Identity Pool.



## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for creating of a Domain-Joined Identity Pool. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.


**Step 1: Create a New Identity Pool.**

The `New-AcctIdentityPool` cmdlet creates a new identity pool. The parameters for this cmdlet are described below.
    
    1. IdentityPoolName
    The name of the identity pool. This must not contain any of the following characters \/;:#.*?=<>|[]()””’

    2. WorkgroupMachine
    Indicates whether the accounts created should be part of a workgroup rather than a domain.	

    3. Domain
    The AD domain name for the pool. Specify this in FQDN format, e.g., "MyDomain.local".	

    3. NamingScheme
    The naming scheme for the identity pool, e.g., "MyVM###"

    4. NamingSchemeType
    The type of naming schemem. This can be "Numeric" or "Alphabetic".

    5. Scope
    The administration scopes associated with this identity pool.

    7. ZoneUid
    The UID that corresponds to the Zone in which AD accounts are created.
    
    8. AllowUnicode.
    Allow the naming scheme to have characters other than alphanumeric characters.


## 4. Common Errors During Operation

1. If the domain is invalid, the error message is "New-AcctIdentityPool : An invalid URL was given for the service.  The value given was 'YourInput.MyDomain.local'."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - New-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/New-AcctIdentityPool.html)
2. [CVAD SDK - Get-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Get-AcctIdentityPool.html)

