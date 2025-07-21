# Machine Catalog Creation

This page explains the details of creating a hosting unit on Citrix Virtual Apps and Desktops (CVAD)


## 1. Add-MachineCatalog.ps1

The `Add-MachineCatalog.ps1` script creates a Machine Catalog and requires the following parameters

    - ZoneUid: The UID that corresponds to the Zone in which these AD accounts will be created
    - NamingScheme: Template for AD account names
    - NamingSchemeType: Naming scheme type for the catalog
    - AdminAddress: The primary DDC address
    - WorkGroupMachine: Indicates whether the accounts created should be part of a workgroup rather than a domain
    - Domain: The AD domain name for the pool. Specify this in FQDN format; for example, MyDomain.local
    - Scope: The administration scopes to be applied
    - ProvisioningSchemeName: Name of the new provisioning scheme
    - ProvisioningSchemeType: The Provisioning Scheme Type
    - HostingUnitName: Name of the hosting unit used
    - NetworkMapping: Specifies how the attached NICs are mapped to networks
    - CustomProperties: Used to provide Container Path(as hypervisor path), vCPU count, Memory, and CPUCores(Cores per CPU) values
    - MasterImageVM: Path to VM snapshot or template
    - VMCpuCount: Number of vCPUs
    - VMMemoryMB: VM memory in MB
    - CleanOnBoot: Reset VM's to their initial state on each power on
    - RunAsynchronously: Run command asynchronously, returns ProvTask ID
    - PersistUserChanges: User data persistence method
    - Count: Number of VMs to create (default is 1)
    - UserName: Username for AD account

It's important to note the usage of the `CleanOnBoot` parameter: Set this to `$True` for creating `a non-persistent catalog` where VMs revert to their original state at each reboot. For `a persistent catalog` where changes are maintained, set it to `$False`. If clean on Boot is set to false, PersistUserChanges must be set

The script can be executed with parameters as shown in the example below:

```powershell
$customProperties = @"
    <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
        <StringProperty Name="ClusterId" Value="00001111-2222-3333-4444-555556666666"/>
        <StringProperty Name="CPUCores" Value="1"/>
    </CustomProperties>
"@

.\Add-MachineCatalog.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -ProvisioningSchemeType MCS `
        -HostingUnitName "myHostngUnit" `
        -Domain "MyDomain.local" `
        -UserName "MyUserName" `
        -Password "MyPassword" `
        -ZoneUid "00000000-0000-0000-0000-000000000000" `
        -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"} `
        -AdminAddress "MyDDC.MyDomain.local" `
        -NamingScheme "MyVM###" `
        -NamingSchemeType "Numeric" `
        -SessionSupport "Single" `
        -AllocationType "Random" `
        -PersistUserChanges "Discard" `
        -CleanOnBoot $True `
        -VMCpuCount 3 `
        -VMMemoryMB 6144 `
        -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
        -CustomProperties $customProperties `
        -Scope @() `
        -Count 2
```

Administrators should tailor these parameters to fit their specific environment.

## 2. Overview of the Script

The script is segmented into some key steps, providing a structured approach to catalog creation:

    1. Create a New Identity Pool.
    2. Create a New Provisioning Scheme.
    3. Create New ProvVMs
        a. Create AD accounts for VMs.
        b. Create VMs
        c. Create New Broker Machines
    4. Create a New Broker Catalog.

Each step can be executed individually by running the associated scripts.