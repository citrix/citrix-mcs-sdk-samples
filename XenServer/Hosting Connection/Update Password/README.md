# Updating the Password of a Hosting Connection

This page outlines the base script for Updating the Password of a Hosting Connection on Citrix Virtual Apps and Desktops (CVAD). 



## 1. Base Script: Update-Password.ps1

The `Update-Password.ps1` script is designed to update the password of an existing hosting connection. It requires the following parameters:

    1. ConnectionName: The name of the hosting connection to update.
    
    2. UserName: The user name of the hypervisor connection.
    
    3. AdminAddress: The primary DDC address.

The script can be executed with parameters as shown in the example below:

```powershell
.\Update-Password.ps1 `
    -ConnectionName "MyConnection" `
    -UserName "MyScope" `
    -AdminAddress "MyDDC.MyDomain.local" `
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of adding scopes is simplified into one key step:

    1. Update the Password of the Hosting Connection.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Update the Password of the Hosting Connection.**

Update the password of a hosting connection by using ``Set-Item``. The parameters for ``Set-Item`` are described below.

    1. LiteralPath.
    Specifies the path of the hosting connection, e.g., "XDHyp:\Connections\MyConnection".

    2. PassThru.
    A flag that, when set, returns the result of the operation.

    3. Password.
    Specifies the password of the hosting connection.

    4. UserName.
    Specifies the user name of the hosting connection.


## 4. Common Errors During Operation

1. If the connection name is invalid, the error message is "Set-Item : The HypervisorConnection object to modify does not exist, therefore invalid."

2. If the credential is invalid, the error message is "Set-Item : The supplied credentials for the connection are not valid."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [Microsoft PowerShell SDK - Set-Item](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-item?view=powershell-7.4)


