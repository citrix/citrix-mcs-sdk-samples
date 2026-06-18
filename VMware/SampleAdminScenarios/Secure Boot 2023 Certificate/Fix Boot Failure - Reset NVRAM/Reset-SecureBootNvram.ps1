<#
.SYNOPSIS
    Resetting Secure Boot NVRAM on VMware VMs.
.DESCRIPTION
    `Reset-SecureBootNvram.ps1` resets Secure Boot NVRAM on VMware VMs so ESXi 8.0.3+
    regenerates the NVRAM with both 2011 and 2023 Secure Boot certificates. This fixes
    VMs that fail to boot with "No Boot Media" because their NVRAM only trusts the 2011
    certificate but the bootloader is signed with 2023.

    Each VM's NVRAM file is scanned for the 2023 certificate before deletion —
    VMs that already have the cert are automatically skipped. The NVRAM file is
    backed up (.nvram.bak) before deletion.

    The script operates in up to 7 phases for efficient batch processing:
      Phase 1: Get VM Details (by name or catalog, with firmware and Secure Boot checks)
      Phase 2: Set Maintenance Mode ON (via Citrix Broker)
      Phase 3: Stop all running VMs (batched async power operations)
      Phase 4: Back up and delete NVRAM files (grouped by datastore, with pre-check)
      Phase 5: Power on all VMs (enabled with -PowerOnAndVerify)
      Phase 6: Verify 2023 cert inside each VM via VMware Tools (enabled with -PowerOnAndVerify and -GuestUsername)
      Phase 7: Set Maintenance Mode OFF (via Citrix Broker)

    By default, VMs are left powered off after NVRAM deletion, waiting for the next
    boot cycle. Use -PowerOnAndVerify to power on VMs and optionally verify certificates
    immediately.
.INPUTS
    1. VMName: One or more VM names. Supports wildcards (e.g., "VDA*"). Cannot be used with CatalogName.
    2. CatalogName: MCS machine catalog name. Resolves all Secure Boot (EFI) VMs in the catalog. Requires Citrix PowerShell SDK. Cannot be used with VMName.
    3. VCenterServer: The vCenter server address to connect to.
    4. VCenterUsername: vCenter username. If provided, you will only be prompted for the password. If omitted, Windows SSO is used.
    5. ForceTurnOff: Force power off VMs that are currently running before deleting NVRAM.
    6. PowerOnAndVerify: Power on VMs after NVRAM deletion and optionally verify certificates. Without this switch, VMs are left powered off after NVRAM deletion.
    7. GuestUsername: Guest OS admin username. When used with -PowerOnAndVerify, enables certificate verification inside the guest OS. Requires VMware Tools.
.OUTPUTS
    1. A timestamped log file with detailed per-VM results in the current directory.
    2. Console output with phase progress, per-VM status, and a summary table.
.NOTES
    Version      : 1.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    # Reset NVRAM for VMs by name. VMs are left powered off after NVRAM deletion.
    .\Reset-SecureBootNvram.ps1 `
        -VMName "VDA001","VDA002" `
        -VCenterServer "vcenter.example.com" `
        -VCenterUsername "administrator@vsphere.local" `
        -ForceTurnOff

    # Reset NVRAM for all Secure Boot VMs in an MCS catalog.
    # VMs are put in maintenance mode, NVRAM is reset, then maintenance mode is turned off.
    # VMs are left powered off after NVRAM deletion.
    .\Reset-SecureBootNvram.ps1 `
        -CatalogName "MyCatalog" `
        -VCenterServer "vcenter.example.com" `
        -VCenterUsername "administrator@vsphere.local" `
        -ForceTurnOff

    # Reset NVRAM and power on VMs with certificate verification.
    .\Reset-SecureBootNvram.ps1 `
        -CatalogName "MyCatalog" `
        -VCenterServer "vcenter.example.com" `
        -VCenterUsername "administrator@vsphere.local" `
        -GuestUsername "YOURDOMAIN\admin" `
        -ForceTurnOff `
        -PowerOnAndVerify

    # Reset NVRAM and power on VMs without certificate verification.
    .\Reset-SecureBootNvram.ps1 `
        -VMName "VDA001","VDA002" `
        -VCenterServer "vcenter.example.com" `
        -VCenterUsername "administrator@vsphere.local" `
        -ForceTurnOff `
        -PowerOnAndVerify

    # Dry run showing what would happen without making any changes.
    .\Reset-SecureBootNvram.ps1 `
        -VMName "VDA001","VDA002" `
        -VCenterServer "vcenter.example.com" `
        -VCenterUsername "administrator@vsphere.local" `
        -ForceTurnOff `
        -WhatIf

    # Dry run with catalog mode and full verification.
    .\Reset-SecureBootNvram.ps1 `
        -CatalogName "MyCatalog" `
        -VCenterServer "vcenter.example.com" `
        -VCenterUsername "administrator@vsphere.local" `
        -GuestUsername "YOURDOMAIN\admin" `
        -ForceTurnOff `
        -PowerOnAndVerify `
        -WhatIf
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = "ByVMName")]
param(
    [Parameter(Mandatory = $true, ParameterSetName = "ByVMName")]
    [string[]]$VMName,
    [Parameter(Mandatory = $true, ParameterSetName = "ByCatalog")]
    [string]$CatalogName,
    [Parameter(Mandatory = $true)]
    [string]$VCenterServer,
    [string]$VCenterUsername,
    [switch]$ForceTurnOff,
    [switch]$PowerOnAndVerify,
    [string]$GuestUsername
)

# =====================
# Code Overview
# =====================
# 1. Logging Functions   - Write-PhaseHeader, Write-PhaseSummary, Write-LogHeader, Write-Banner, Write-Summary
# 2. Utility Functions   - Initialization, Write-Log, Add-Result, Update-ResultVerified, Get-NvramPath,
#                          Initialize-VMwareConnection, Initialize-GuestOSCredential
# 3. Core Functions      - Phase 1: Get-VMsFromCatalog, Get-VMsFromNames
#                          Phase 2: Set-MaintenanceMode
#                          Phase 3: Stop-VMs
#                          Phase 4: Delete-NVRAM
#                          Phase 5: Start-VMs (with -PowerOnAndVerify)
#                          Phase 6: Verify-Certs (with -PowerOnAndVerify and -GuestUsername)
#                          Phase 7: Set-MaintenanceMode OFF
# 4. Main Execution      - Initialize connections, resolve VMs, run phases 1-7

# =====================
# 1. Logging & Display
# =====================

# Initialize error handling and batch size for async VM operations
$ErrorActionPreference = "Stop"
$BatchSize = 10

# Create timestamped log file, e.g., Reset-SecureBootNvram_20260505_143000.log
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$script:logFile = Join-Path (Get-Location) "Reset-SecureBootNvram_$timestamp.log"

# Initialize results tracking
$script:results = @{
    Total     = 0
    Success   = 0
    Skipped   = 0
    Failed    = 0
    Details   = [System.Collections.ArrayList]::new()
}

# Display a phase header banner in the console
# e.g., Write-PhaseHeader -Phase 1 -TotalPhases 4 -Title "Stopping running VMs"
function Write-PhaseHeader {
    param(
        [int]$Phase,
        [int]$TotalPhases,
        [string]$Title
    )
    $header = "Phase $Phase/$TotalPhases : $Title"
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  $header" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Log -Message "========== $header ==========" -Level "INFO" -LogOnly
}

# Display a one-line phase summary after completion
function Write-PhaseSummary {
    param(
        [int]$Phase,
        [int]$TotalPhases,
        [string]$Summary
    )
    Write-Host ""
    Write-Host "  $Summary" -ForegroundColor White
    Write-Log -Message "========== Phase $Phase/$TotalPhases Summary: $Summary ==========" -Level "INFO" -LogOnly
}

# Write script parameters and settings to the log file header
function Write-LogHeader {
    if (-not $script:logFile) { return }

    $vmParam = if ($VMName) { $VMName -join ", " } else { "(via catalog)" }
    $catParam = if ($CatalogName) { $CatalogName } else { "(not specified)" }
    $userParam = if ($VCenterUsername) { $VCenterUsername } else { "(Windows SSO)" }

    $header = @"
============================================================
  Reset-SecureBootNvram Log
  Started: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
============================================================
  VCenterServer:    $VCenterServer
  Username:         $userParam
  VMName:           $vmParam
  CatalogName:      $catParam
  ForceTurnOff:     $ForceTurnOff
  BatchSize:        $BatchSize
  WhatIf:           $WhatIfPreference
============================================================
"@
    Set-Content -Path $script:logFile -Value $header -ErrorAction SilentlyContinue
}

# Display the startup banner with warnings about BitLocker and custom certs
function Write-Banner {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Reset-SecureBootNvram - Secure Boot 2023 Certificate Fix" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "WARNING: This script backs up and deletes .nvram files from VMware VMs." -ForegroundColor Yellow
    Write-Host "  - ESXi will regenerate NVRAM with updated Secure Boot certs on next boot." -ForegroundColor Yellow
    Write-Host "  - If BitLocker is enabled on any VM, NVRAM deletion may trigger" -ForegroundColor Yellow
    Write-Host "    BitLocker recovery mode. Ensure recovery keys are available." -ForegroundColor Yellow
    Write-Host "  - Any custom Secure Boot certificate configurations will be reset" -ForegroundColor Yellow
    Write-Host "    to ESXi defaults." -ForegroundColor Yellow
    Write-Host ""
    if ($WhatIfPreference) {
        Write-Host "  MODE: DRY-RUN (no changes will be made)" -ForegroundColor Magenta
        Write-Host ""
    }
}

# Display final summary table with per-VM results and next steps
function Write-Summary {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Summary" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Total VMs:  $($script:results.Total)"
    Write-Host "  Success:    $($script:results.Success)" -ForegroundColor Green
    Write-Host "  Skipped:    $($script:results.Skipped)" -ForegroundColor Yellow
    Write-Host "  Failed:     $($script:results.Failed)" -ForegroundColor Red
    Write-Host ""

    if ($script:results.Details.Count -gt 0) {
        $maxMsgLen = 80
        $displayData = $script:results.Details | ForEach-Object {
            $msg = $_.Message
            if ($msg.Length -gt $maxMsgLen) { $msg = $msg.Substring(0, $maxMsgLen) + "..." }
            if ($script:RunVerification) {
                [PSCustomObject]@{ VMName = $_.VMName; Status = $_.Status; Verified = $_.Verified; Message = $msg }
            }
            else {
                [PSCustomObject]@{ VMName = $_.VMName; Status = $_.Status; Message = $msg }
            }
        }
        $displayData | Format-Table -AutoSize
    }

    if ($script:RunVerification) {
        $failedVerifications = $script:results.Details | Where-Object { $_.Verified -in @("No", "Error") }
        if ($failedVerifications) {
            Write-Host ""
            Write-Host "WARNING: The following VMs failed post-boot verification:" -ForegroundColor Red
            foreach ($f in $failedVerifications) {
                Write-Host "  $($f.VMName) - $($f.Message)" -ForegroundColor Red
            }
            Write-Host ""
        }
    }

    if ($script:results.Success -gt 0) {
        Write-Host ""
        Write-Host "IMPORTANT: If BitLocker is enabled on any processed VM," -ForegroundColor Yellow
        Write-Host "  it may enter recovery mode on next boot." -ForegroundColor Yellow
        Write-Host "  Have BitLocker recovery keys ready." -ForegroundColor Yellow

        if (-not $script:RunVerification) {
            Write-Host ""
            Write-Host "Next steps:" -ForegroundColor Green
            Write-Host "  1. Verify VMs booted successfully" -ForegroundColor Green
            Write-Host "  2. Verify the 2023 cert inside each VM:" -ForegroundColor Green
            Write-Host '     [System.Text.Encoding]::ASCII.GetString((Get-SecureBootUEFI db).bytes) -match "Windows UEFI CA 2023"' -ForegroundColor Green
        }
    }

    if ($script:logFile -and (Test-Path $script:logFile)) {
        Write-Host ""
        Write-Host "Log file: $($script:logFile)" -ForegroundColor Cyan
    }
}

# Write a message to both log file and console with color-coded level
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")]
        [string]$Level = "INFO",
        [string]$VM = "",
        [switch]$ConsoleOnly,
        [switch]$LogOnly
    )
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $vmTag = if ($VM) { "[$VM] " } else { "" }
    $logLine = "[$ts] [$Level] ${vmTag}$Message"

    if (-not $ConsoleOnly -and $script:logFile) {
        Add-Content -Path $script:logFile -Value $logLine -ErrorAction SilentlyContinue
    }

    if (-not $LogOnly) {
        $color = switch ($Level) {
            "ERROR"   { "Red" }
            "WARN"    { "Yellow" }
            "SUCCESS" { "Green" }
            default   { $null }
        }
        $consoleMsg = "  ${vmTag}$Message"
        if ($color) { Write-Host $consoleMsg -ForegroundColor $color }
        else { Write-Host $consoleMsg }
    }

    Write-Verbose $logLine
}

# =====================
# 2. Utility Functions
# =====================

# Add a result entry and update summary counts
function Add-Result {
    param(
        [string]$VM,
        [string]$Status,
        [string]$Message,
        [string]$Verified = "N/A"
    )
    $null = $script:results.Details.Add([PSCustomObject]@{
        VMName   = $VM
        Status   = $Status
        Verified = $Verified
        Message  = $Message
    })
    switch ($Status) {
        "Success" { $script:results.Success++ }
        "Skipped" { $script:results.Skipped++ }
        "Failed"  { $script:results.Failed++ }
    }
    $script:results.Total++
}

# Update an existing result entry (Verified, Status, and/or Message)
function Update-ResultVerified {
    param(
        [string]$VM,
        [string]$Verified,
        [string]$Status,
        [string]$Message
    )
    $entry = $script:results.Details | Where-Object { $_.VMName -eq $VM } | Select-Object -Last 1
    if ($entry) {
        if ($Verified) { $entry.Verified = $Verified }
        if ($Message) { $entry.Message = $Message }
        if ($Status -and $Status -ne $entry.Status) {
            switch ($entry.Status) {
                "Success" { $script:results.Success-- }
                "Skipped" { $script:results.Skipped-- }
                "Failed"  { $script:results.Failed-- }
            }
            $entry.Status = $Status
            switch ($Status) {
                "Success" { $script:results.Success++ }
                "Skipped" { $script:results.Skipped++ }
                "Failed"  { $script:results.Failed++ }
            }
        }
    }
}

# Get the NVRAM file path from VM configuration
function Get-NvramPath {
    param(
        [Parameter(Mandatory)]$VM
    )

    $vmView = $VM | Get-View
    $nvramFile = $vmView.Config.Files.NvramFile

    if ([string]::IsNullOrEmpty($nvramFile)) {
        $vmxPath = $vmView.Config.Files.VmPathName
        if ($vmxPath -match '\[(.+?)\]\s*(.+)\.vmx$') {
            # Matches (Auto populated by regex match). e.g., [datastore1] VMFolder/VMName.vmx
            $datastoreName = $Matches[1] # Match (.+?) -> the datastore name
            $vmFolder = $Matches[2] # Match (.+) -> the VM folder/path
            $nvramFile = "[$datastoreName] $vmFolder.nvram"
        }
        else {
            throw "Cannot determine NVRAM file path from VM configuration."
        }
    }

    return $nvramFile
}

# Verify PowerCLI is loaded, connect to vCenter, and log version info
function Initialize-VMwareConnection {
    if (-not (Get-Module VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {
        Write-Log -Message "VMware PowerCLI module is not loaded." -Level "ERROR"
        Write-Log -Message "  Import-Module VMware.PowerCLI" -Level "ERROR"
        Write-Log -Message "  Install with: Install-Module VMware.PowerCLI -Scope CurrentUser" -Level "INFO"
        exit 1
    }

    $pcliVersion = (Get-Module VMware.PowerCLI -ErrorAction SilentlyContinue).Version
    if ($pcliVersion) {
        Write-Log -Message "PowerCLI version: $pcliVersion" -Level "INFO" -LogOnly
    }

    $savedWhatIf = $WhatIfPreference
    $WhatIfPreference = $false
    $script:savedCertAction = (Get-PowerCLIConfiguration -Scope Session -ErrorAction SilentlyContinue).InvalidCertificateAction
    Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
    $WhatIfPreference = $savedWhatIf

    Write-Log -Message "Connecting to vCenter: $VCenterServer ..." -Level "INFO"
    $savedWhatIf = $WhatIfPreference
    $WhatIfPreference = $false
    try {
        if ($VCenterUsername) {
            $cred = Get-Credential -UserName $VCenterUsername -Message "Enter vCenter password for $VCenterUsername"
            $null = Connect-VIServer -Server $VCenterServer -Credential $cred -ErrorAction Stop
        }
        else {
            $null = Connect-VIServer -Server $VCenterServer -ErrorAction Stop
        }
        Write-Log -Message "Connected to vCenter successfully." -Level "SUCCESS"
    }
    catch {
        Write-Log -Message "Failed to connect to vCenter - $_" -Level "ERROR"
        exit 1
    }
    $WhatIfPreference = $savedWhatIf

    try {
        $vcVersion = $global:DefaultVIServer.Version
        $vcBuild = $global:DefaultVIServer.Build
        Write-Log -Message "vCenter version: $vcVersion (build $vcBuild)" -Level "INFO" -LogOnly
    }
    catch {
        Write-Log -Message "Could not retrieve vCenter version." -Level "WARN" -LogOnly
    }
}

# Prompt for guest OS credentials and calculate total phases
function Initialize-GuestOSCredential {
    if ($PowerOnAndVerify -and $GuestUsername) {
        $script:GuestCredential = Get-Credential -UserName $GuestUsername -Message "Enter guest OS password for $GuestUsername"
        $script:RunVerification = $true
    }
    else {
        $script:RunVerification = $false
    }

    $phases = 5  # Base: Get VM Details, Maintenance ON, Stop VMs, Delete NVRAM, Maintenance OFF
    if ($PowerOnAndVerify) { $phases += 1 }
    if ($script:RunVerification) { $phases += 1 }
    $script:TotalPhases = $phases
}

function Initialize-CitrixModule {
    $citrixLoaded = (Get-PSSnapin Citrix.* -ErrorAction SilentlyContinue) -or
                    (Get-Module Citrix.MachineCreation.Admin.V2 -ErrorAction SilentlyContinue)
    if (-not $citrixLoaded) {
        Write-Log -Message "Citrix PowerShell SDK is not loaded." -Level "ERROR"
        Write-Log -Message "  On-premises: Add-PSSnapin Citrix.*" -Level "ERROR"
        Write-Log -Message "  Citrix Cloud: Import-Module Citrix.MachineCreation.Admin.V2" -Level "ERROR"
        exit 1
    }
    $loadedSnapins = (Get-PSSnapin Citrix.* -ErrorAction SilentlyContinue |
                      Select-Object -ExpandProperty Name) -join ", "
    $loadedModules = (Get-Module Citrix.* -ErrorAction SilentlyContinue |
                      Select-Object -ExpandProperty Name) -join ", "
    $loadedDetail  = (@($loadedSnapins, $loadedModules) | Where-Object { $_ }) -join ", "
    Write-Log -Message "Citrix PowerShell SDK verified: $loadedDetail" -Level "SUCCESS" -LogOnly
}

# =====================
# 3. Core Functions
# =====================
# Phase 1: Get VMs from an MCS catalog.
function Get-VMsFromCatalog {
    param([string]$CatalogName)

    Write-Log -Message "Catalog mode: resolving VMs from catalog '$CatalogName'" -Level "INFO"

    try {
        $scheme = Get-ProvScheme -ProvisioningSchemeName $CatalogName -ErrorAction Stop
        Write-Log -Message "Catalog '$CatalogName' verified (ProvScheme UID: $($scheme.ProvisioningSchemeUid))." -Level "SUCCESS"
        $machines = @(Get-ProvVM -ProvisioningSchemeUid $scheme.ProvisioningSchemeUid -ErrorAction Stop)
        if ($machines.Count -eq 0) {
            Write-Log -Message "No VMs found in catalog '$CatalogName'." -Level "WARN"
            exit 0
        }
        Write-Log -Message "Found $($machines.Count) VM(s) in catalog '$CatalogName'." -Level "SUCCESS"
    }
    catch {
        $errMsg = $_.Exception.Message
        Write-Log -Message "Cannot retrieve VMs from catalog '$CatalogName': $errMsg" -Level "ERROR"
        Write-Host ""
        if ($errMsg -match "registry access" -or $errMsg -match "UnauthorizedAccessException") {
            Write-Host "  This error typically means the Citrix SDK cannot read the registry to" -ForegroundColor Yellow
            Write-Host "  find the Delivery Controller (DDC) address." -ForegroundColor Yellow
            Write-Host ""
        }
        Write-Host "  Try one of the following:" -ForegroundColor Yellow
        Write-Host "    On-premises:" -ForegroundColor White
        Write-Host "      1. Run PowerShell as Administrator" -ForegroundColor White
        Write-Host "      2. Run this script directly on a Delivery Controller" -ForegroundColor White
        Write-Host "    Citrix Cloud:" -ForegroundColor White
        Write-Host "      3. Run Get-XDAuthentication before running this script" -ForegroundColor White
        Write-Host "    Or:" -ForegroundColor White
        Write-Host "      4. Use -VMName to specify VMs directly instead of -CatalogName" -ForegroundColor White
        Write-Host ""
        exit 1
    }

    Write-Host ""
    Write-Host "  CATALOG: $CatalogName" -ForegroundColor Cyan
    Write-Host "  VMs in catalog:" -ForegroundColor White
    foreach ($machine in $machines) {
        $mName = $machine.VMName
        Write-Host "    - $mName" -ForegroundColor White
        Write-Log -Message "Catalog VM: $mName (VMId: $($machine.VMId))" -Level "INFO" -LogOnly
    }
    Write-Host ""

    Write-Log -Message "Resolving catalog VMs to VMware VMs and checking firmware type..." -Level "INFO" -LogOnly
    $vms = @()
    $efiCount = 0
    $biosCount = 0
    $notFoundCount = 0
    foreach ($machine in $machines) {
        $hostedMachineName = $machine.VMName

        $found = Get-VM -Name $hostedMachineName -ErrorAction SilentlyContinue
        if ($found) {
            $vmView = $found | Get-View
            $fwType = $vmView.Config.Firmware
            $sbEnabled = $vmView.Config.BootOptions.EfiSecureBootEnabled
            Write-Log -VM $hostedMachineName -Message "Firmware: $fwType, SecureBoot: $sbEnabled" -Level "INFO" -LogOnly
            if ($fwType -eq "efi") {
                $vms = @($vms) + @($found)
                $efiCount++
            }
            else {
                $biosCount++
                Write-Log -VM $hostedMachineName -Message "BIOS firmware - skipped (not affected)." -Level "INFO" -LogOnly
            }
        }
        else {
            $notFoundCount++
            Write-Log -VM $hostedMachineName -Message "VM not found in vCenter '$VCenterServer' - skipped." -Level "WARN"
            Add-Result -VM $hostedMachineName -Status "Skipped" -Message "VM not found in vCenter"
        }
    }

    Write-Host "  VM resolution summary:" -ForegroundColor White
    Write-Host "    EFI + Secure Boot (will be processed): $efiCount" -ForegroundColor Green
    if ($biosCount -gt 0) {
        Write-Host "    BIOS firmware (skipped - not affected):  $biosCount" -ForegroundColor Yellow
    }
    if ($notFoundCount -gt 0) {
        Write-Host "    Not found in vCenter (skipped):          $notFoundCount" -ForegroundColor Yellow
    }
    Write-Host ""

    if ($efiCount -gt 0) {
        Write-Host "  This will process all $efiCount EFI VM(s) in this catalog." -ForegroundColor White
        Write-Host ""
        Write-Host "  Why all VMs in the catalog?" -ForegroundColor Yellow
        Write-Host "  For non-persistent MCS catalogs, the virtual disk resets from the" -ForegroundColor Yellow
        Write-Host "  master image on every reboot, but the NVRAM file persists on the" -ForegroundColor Yellow
        Write-Host "  datastore. After a catalog update with a 2023-signed bootloader," -ForegroundColor Yellow
        Write-Host "  every VM's NVRAM may still only trust the old 2011 certificate." -ForegroundColor Yellow
        Write-Host "  Each VM's NVRAM will be scanned for the 2023 cert before deletion." -ForegroundColor Yellow
        Write-Host "  VMs that already have the cert will be automatically skipped." -ForegroundColor Yellow
        Write-Host ""

        Write-Host "  VMs to be processed:" -ForegroundColor White
        foreach ($v in $vms) {
            Write-Host "    - $($v.Name) (Power: $($v.PowerState))" -ForegroundColor White
        }
        Write-Host ""

        if ($WhatIfPreference) {
            Write-Host "  (DRY-RUN: No changes will be made)" -ForegroundColor Magenta
        }
    }

    return @($vms)
}

# Phase 1: Get VMs by name(s). Filters to EFI firmware only, matching catalog mode behavior.
function Get-VMsFromNames {
    param([string[]]$VMName)

    $vms = @()
    foreach ($name in $VMName) {
        $found = @(Get-VM -Name $name -ErrorAction SilentlyContinue)
        if ($found.Count -gt 0) {
            foreach ($vm in $found) {
                $vmView = $vm | Get-View
                if ($vmView.Config.Firmware -eq "efi") {
                    $vms = @($vms) + @($vm)
                }
                else {
                    Write-Log -VM $vm.Name -Message "BIOS firmware - skipped (not affected by Secure Boot issue)." -Level "INFO"
                    Add-Result -VM $vm.Name -Status "Skipped" -Message "BIOS firmware - not affected"
                }
            }
        }
        else {
            Write-Log -VM $name -Message "No VM found matching '$name'" -Level "WARN"
            Add-Result -VM $name -Status "Skipped" -Message "VM not found"
        }
    }
    return @($vms)
}

# Set maintenance mode ON or OFF for VMs via Citrix Broker (catalog mode only)
function Set-MaintenanceMode {
    param(
        [array]$VMs,
        [bool]$Enable,
        [int]$PhaseNum,
        [int]$TotalPhases
    )

    $action = if ($Enable) { "ON" } else { "OFF" }
    Write-PhaseHeader -Phase $PhaseNum -TotalPhases $TotalPhases -Title "Setting maintenance mode $action ($($VMs.Count) VMs)"

    if ($VMs.Count -eq 0) {
        Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "No VMs to update."
        return
    }

    if ($WhatIfPreference) {
        foreach ($vm in $VMs) {
            Write-Host "  [$($vm.Name)] WOULD set maintenance mode $action." -ForegroundColor Magenta
        }
        Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "DRY-RUN: Would set maintenance mode $action for $($VMs.Count) VM(s)."
        return
    }

    $successCount = 0
    $failedCount = 0
    $skippedCount = 0

    foreach ($vm in $VMs) {
        try {
            $brokerMachine = Get-BrokerMachine -HostedMachineName $vm.Name -ErrorAction SilentlyContinue
            if ($brokerMachine) {
                Set-BrokerMachine -InputObject $brokerMachine -InMaintenanceMode $Enable
                Write-Log -VM $vm.Name -Message "Maintenance mode set to $action." -Level "SUCCESS"
                $successCount++
            }
            else {
                Write-Log -VM $vm.Name -Message "Not found in Citrix Broker. Skipping maintenance mode." -Level "WARN"
                $skippedCount++
            }
        }
        catch {
            Write-Log -VM $vm.Name -Message "Failed to set maintenance mode: $_" -Level "ERROR"
            $failedCount++
        }
    }

    Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "$successCount set to $action, $skippedCount skipped, $failedCount failed."
}

# Power off running VMs in batches using async Stop-VM
function Stop-VMs {
    param(
        [array]$VMs,
        [int]$PhaseNum,
        [int]$TotalPhases
    )

    Write-PhaseHeader -Phase $PhaseNum -TotalPhases $TotalPhases -Title "Stopping running VMs"

    # Separate running and already powered off VMs
    $runningVMs = @($VMs | Where-Object { $_.PowerState -ne "PoweredOff" })
    $alreadyOff = @($VMs | Where-Object { $_.PowerState -eq "PoweredOff" })
    Write-Log -Message "$($alreadyOff.Count) VM(s) already powered off, $($runningVMs.Count) need stopping." -Level "INFO"

    # If no VMs need stopping, summarize and return
    if ($runningVMs.Count -eq 0) {
        Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "All $($VMs.Count) VM(s) already powered off. Nothing to stop."
        return $VMs
    }

    # If some VMs are running but -ForceTurnOff not specified, skip them and summarize
    if (-not $ForceTurnOff) {
        Write-Log -Message "$($runningVMs.Count) VM(s) are running but -ForceTurnOff not specified. These VMs will be skipped." -Level "WARN"
        foreach ($vm in $runningVMs) {
            Add-Result -VM $vm.Name -Status "Skipped" -Message "VM is powered on. Use -ForceTurnOff to force shutdown."
        }
        Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "$($alreadyOff.Count) already off, $($runningVMs.Count) skipped (use -ForceTurnOff)."
        return $alreadyOff
    }

    # For Dry Run, just summarize how many would be stopped and return
    if ($WhatIfPreference) {
        $batchCount = [Math]::Ceiling($runningVMs.Count / $BatchSize)
        Write-Host "  WOULD stop $($runningVMs.Count) running VM(s) in $batchCount batch(es) of $BatchSize." -ForegroundColor Magenta
        Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "DRY-RUN: Would stop $($runningVMs.Count) VM(s)."
        return $VMs
    }

    $stoppedVMs = [System.Collections.ArrayList]::new()
    $stoppedVMs.AddRange($alreadyOff)
    $failedStop = 0
    $totalBatches = [Math]::Ceiling($runningVMs.Count / $BatchSize)

    # Stop VMs in batches 
    for ($b = 0; $b -lt $totalBatches; $b++) {
        $start = $b * $BatchSize
        $end = [Math]::Min($start + $BatchSize, $runningVMs.Count)
        $batch = @($runningVMs[$start..($end - 1)])
        $batchNum = $b + 1

        Write-Host ""
        Write-Host "  Batch $batchNum/$totalBatches (VMs $($start + 1)-$end of $($runningVMs.Count))..." -ForegroundColor White

        # Send stop commands for this batch
        foreach ($vm in $batch) {
            Write-Log -VM $vm.Name -Message "Sending Stop-VM..." -Level "INFO" -LogOnly
            try {
                Stop-VM -VM $vm -Confirm:$false -RunAsync | Out-Null
            }
            catch {
                Write-Log -VM $vm.Name -Message "Graceful stop failed, trying force..." -Level "WARN" -LogOnly
                try {
                    Stop-VM -VM $vm -Kill -Confirm:$false -RunAsync | Out-Null
                }
                catch {
                    Write-Log -VM $vm.Name -Message "FAILED to send stop command: $_" -Level "ERROR"
                    Add-Result -VM $vm.Name -Status "Failed" -Message "Failed to stop VM: $_"
                    $failedStop++
                }
            }
        }

        # Poll this batch until all powered off or timeout
        $pendingNames = [System.Collections.Generic.HashSet[string]]::new()
        foreach ($vm in $batch) {
            $existing = $script:results.Details | Where-Object { $_.VMName -eq $vm.Name -and $_.Status -eq "Failed" }
            if (-not $existing) {
                $null = $pendingNames.Add($vm.Name)
            }
        }

        $timeout = 120
        $elapsed = 0
        
        # Poll every 5 seconds until all pending VMs are powered off or timeout reached
        while ($pendingNames.Count -gt 0 -and $elapsed -lt $timeout) {
            Start-Sleep -Seconds 5
            $elapsed += 5
            $nowDone = @()
            
            # Check power state of pending VMs
            foreach ($name in $pendingNames) {
                $currentVM = Get-VM -Name $name -ErrorAction SilentlyContinue
                if ($currentVM -and $currentVM.PowerState -eq "PoweredOff") {
                    $nowDone += $name
                }
            }

            # Update results for any VMs that are now powered off
            foreach ($name in $nowDone) {
                Write-Log -VM $name -Message "Powered off successfully." -Level "SUCCESS"
                $null = $pendingNames.Remove($name)
                $vmObj = $batch | Where-Object { $_.Name -eq $name }
                if ($vmObj) { $null = $stoppedVMs.Add($vmObj) }
            }
            if ($pendingNames.Count -gt 0) {
                Write-Log -Message "Waiting for $($pendingNames.Count) VM(s) to power off... ($elapsed/${timeout}s)" -Level "INFO" -LogOnly
            }
        }

        # Handle timeouts: escalate to force stop (-Kill) in parallel
        if ($pendingNames.Count -gt 0) {
            Write-Log -Message "$($pendingNames.Count) VM(s) did not power off within ${timeout}s. Force stopping..." -Level "WARN"
            foreach ($name in @($pendingNames)) {
                try {
                    Stop-VM -VM (Get-VM -Name $name) -Kill -Confirm:$false -RunAsync | Out-Null
                    Write-Log -VM $name -Message "Force stop command sent." -Level "INFO" -LogOnly
                }
                catch {
                    Write-Log -VM $name -Message "FAILED: Force stop failed: $_" -Level "ERROR"
                    Add-Result -VM $name -Status "Failed" -Message "Force stop failed: $_"
                    $null = $pendingNames.Remove($name)
                    $failedStop++
                }
            }

            # Poll until force-stopped VMs are powered off (shorter timeout)
            $killTimeout = 30
            $killElapsed = 0
            while ($pendingNames.Count -gt 0 -and $killElapsed -lt $killTimeout) {
                Start-Sleep -Seconds 5
                $killElapsed += 5
                foreach ($name in @($pendingNames)) {
                    $currentVM = Get-VM -Name $name -ErrorAction SilentlyContinue
                    if ($currentVM -and $currentVM.PowerState -eq "PoweredOff") {
                        Write-Log -VM $name -Message "Force stop successful." -Level "SUCCESS"
                        $null = $pendingNames.Remove($name)
                        $vmObj = $batch | Where-Object { $_.Name -eq $name }
                        if ($vmObj) { $null = $stoppedVMs.Add($vmObj) }
                    }
                }
            }

            foreach ($name in @($pendingNames)) {
                Write-Log -VM $name -Message "FAILED: Did not power off after force stop." -Level "ERROR"
                Add-Result -VM $name -Status "Failed" -Message "Did not power off after force stop"
                $failedStop++
            }
        }

        Write-Host "  Batch $batchNum complete." -ForegroundColor White
    }

    $stoppedCount = $stoppedVMs.Count
    Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "$stoppedCount stopped, $failedStop failed, $($alreadyOff.Count) were already off."
    return $stoppedVMs.ToArray()
}

# Phase 3: Scan NVRAM for 2023 cert, backup and delete if not present, grouped by datastore
function Delete-NVRAM {
    param(
        [array]$VMs,
        [int]$PhaseNum,
        [int]$TotalPhases
    )

    Write-PhaseHeader -Phase $PhaseNum -TotalPhases $TotalPhases -Title "Checking and deleting NVRAM files ($($VMs.Count) VMs)"

    Write-Host "  Each NVRAM file will be scanned for the 2023 cert before deletion." -ForegroundColor White
    Write-Host "  VMs with the cert already present will be skipped." -ForegroundColor White
    Write-Host ""

    $deletedVMs = [System.Collections.ArrayList]::new()
    $failedCount = 0
    $skippedCount = 0
    $preCheckSkippedCount = 0
    $total = $VMs.Count

    # Group VMs by datastore to mount PSDrive once per datastore
    $datastoreGroups = [ordered]@{}
    for ($i = 0; $i -lt $total; $i++) {
        $vm = $VMs[$i]
        $vmName = $vm.Name
        $counter = "[$($i + 1)/$total]"

        # Check firmware type
        try {
            $vmView = $vm | Get-View
            $firmware = $vmView.Config.Firmware
            
            # If not EFI, skip this VM (not affected)
            if ($firmware -ne "efi") {
                Write-Log -Message "$counter $vmName - SKIPPED: BIOS firmware." -Level "WARN"
                Add-Result -VM $vmName -Status "Skipped" -Message "BIOS firmware, not EFI."
                $skippedCount++
                continue
            }

            # Check if Secure Boot is enabled and log a warning if not (but proceed anyway)
            $secureBoot = $vmView.Config.BootOptions.EfiSecureBootEnabled
            if (-not $secureBoot) {
                Write-Log -VM $vmName -Message "Secure Boot is NOT enabled. Proceeding anyway." -Level "WARN" -LogOnly
            }
        }
        catch {
            Write-Log -Message "$counter $vmName - FAILED: Cannot read VM config: $_" -Level "ERROR"
            Add-Result -VM $vmName -Status "Failed" -Message "Cannot read VM config: $_"
            $failedCount++
            continue
        }

        # Get NVRAM path
        try {
            $nvramPath = Get-NvramPath -VM $vm
            Write-Log -VM $vmName -Message "NVRAM path: $nvramPath" -Level "INFO" -LogOnly
        }
        catch {
            Write-Log -Message "$counter $vmName - FAILED: Cannot determine NVRAM path: $_" -Level "ERROR"
            Add-Result -VM $vmName -Status "Failed" -Message "Cannot determine NVRAM path: $_"
            $failedCount++
            continue
        }

        # Parse datastore and file path
        if ($nvramPath -match '\[(.+?)\]\s*(.+)') {
            $dsName = $Matches[1]
            $filePath = $Matches[2]
        }
        else {
            Write-Log -Message "$counter $vmName - FAILED: Cannot parse NVRAM path." -Level "ERROR"
            Add-Result -VM $vmName -Status "Failed" -Message "Cannot parse NVRAM path: $nvramPath"
            $failedCount++
            continue
        }

        # Group by datastore
        if (-not $datastoreGroups.Contains($dsName)) {
            $datastoreGroups[$dsName] = [System.Collections.ArrayList]::new()
        }
        $null = $datastoreGroups[$dsName].Add(@{
            VM       = $vm
            FilePath = $filePath
            NvramPath = $nvramPath
            Index    = $i
        })
    }

    # Process each datastore group
    $processedCount = 0
    $dsIndex = 0
    foreach ($dsName in $datastoreGroups.Keys) {
        $group = $datastoreGroups[$dsName]
        Write-Log -Message "Processing $($group.Count) VM(s) on datastore '$dsName'..." -Level "INFO"

        # Mount PSDrive once for this datastore
        $driveName = "nvramDS_${dsIndex}"
        $dsIndex++
        $savedWhatIf = $WhatIfPreference
        $WhatIfPreference = $false
        
        # Try to mount the datastore as a PSDrive for file operations. If this fails, mark all VMs in this group as failed and skip.
        try {
            $datastore = Get-Datastore -Name $dsName -ErrorAction Stop
            $null = New-PSDrive -Name $driveName -Location $datastore -PSProvider VimDatastore -Root "\" -ErrorAction Stop
        }
        catch {
            $WhatIfPreference = $savedWhatIf
            Write-Log -Message "FAILED: Cannot mount datastore '$dsName': $_" -Level "ERROR"
            foreach ($entry in $group) {
                Add-Result -VM $entry.VM.Name -Status "Failed" -Message "Cannot mount datastore '$dsName': $_"
                $failedCount++
            }
            continue
        }
        $WhatIfPreference = $savedWhatIf

        # Process each VM in this datastore group
        try {
            foreach ($entry in $group) {
                $vm = $entry.VM
                $vmName = $vm.Name
                $filePath = $entry.FilePath
                $nvramPath = $entry.NvramPath
                $processedCount++
                $counter = "[$processedCount/$total]"

                $fullPath = "${driveName}:\$filePath"

                # Check if NVRAM file exists
                $savedWhatIf2 = $WhatIfPreference
                $WhatIfPreference = $false
                $nvramExists = Test-Path -Path $fullPath
                $WhatIfPreference = $savedWhatIf2

                # If NVRAM file doesn't exist, log a warning and skip this VM
                if (-not $nvramExists) {
                    Write-Log -Message "$counter $vmName - SKIPPED: NVRAM file not found." -Level "WARN"
                    Add-Result -VM $vmName -Status "Skipped" -Message "NVRAM file not found at $nvramPath"
                    $skippedCount++
                    continue
                }

                # Pre-check: scan NVRAM for 2023 cert before deleting
                $tempDir = [System.IO.Path]::GetTempPath()
                $tempFile = Join-Path $tempDir "$vmName.nvram.tmp"
                try {
                    $savedWhatIf3 = $WhatIfPreference
                    $WhatIfPreference = $false
                    Copy-DatastoreItem -Item $fullPath -Destination $tempFile -Force
                    $WhatIfPreference = $savedWhatIf3

                    $nvramBytes = [System.IO.File]::ReadAllBytes($tempFile)
                    $nvramText = [System.Text.Encoding]::ASCII.GetString($nvramBytes)
                    $hasCert2023 = $nvramText -match "Windows UEFI CA 2023"

                    # If cert is found, skip deletion for this VM
                    if ($hasCert2023) {
                        Write-Log -Message "$counter $vmName - SKIPPED: 2023 cert already present in NVRAM. No reset needed." -Level "SUCCESS"
                        Add-Result -VM $vmName -Status "Skipped" -Verified "Yes" -Message "2023 cert already present in NVRAM. No reset needed."
                        $preCheckSkippedCount++
                        $skippedCount++
                        continue
                    }
                    else {
                        Write-Log -VM $vmName -Message "Pre-check: 2023 cert NOT found in NVRAM. Reset needed." -Level "INFO" -LogOnly
                    }
                }
                catch {
                    Write-Log -VM $vmName -Message "Pre-check failed: $_. Proceeding with NVRAM deletion." -Level "WARN" -LogOnly
                }
                finally {
                    if (Test-Path $tempFile -ErrorAction SilentlyContinue) {
                        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
                    }
                }

                # For Dry Run, just log that we would back up and delete the NVRAM file if the cert is not found, and mark this VM as "would delete"
                if ($WhatIfPreference) {
                    Write-Log -Message "$counter $vmName - DRY-RUN: Would back up and delete $nvramPath (2023 cert not found)." -Level "INFO"
                    Add-Result -VM $vmName -Status "Success" -Message "DRY-RUN: Would back up and delete $nvramPath"
                    $null = $deletedVMs.Add($vm)
                }
                else {
                    # Backup NVRAM
                    $backupPath = "${driveName}:\${filePath}.bak"
                    try {
                        Copy-DatastoreItem -Item $fullPath -Destination $backupPath -Force
                        Write-Log -VM $vmName -Message "Backed up to $nvramPath.bak" -Level "INFO" -LogOnly
                    }
                    catch {
                        Write-Log -VM $vmName -Message "Backup failed: $_. Proceeding anyway." -Level "WARN" -LogOnly
                    }

                    # Delete NVRAM
                    try {
                        Remove-Item -Path $fullPath -Force
                        Write-Log -Message "$counter $vmName - Backed up, NVRAM deleted." -Level "SUCCESS"
                        Add-Result -VM $vmName -Status "Success" -Message "NVRAM backed up and deleted. ESXi will regenerate on next boot."
                        $null = $deletedVMs.Add($vm)
                    }
                    catch {
                        Write-Log -Message "$counter $vmName - FAILED: Could not delete NVRAM: $_" -Level "ERROR"
                        Add-Result -VM $vmName -Status "Failed" -Message "Failed to delete NVRAM: $_"
                        $failedCount++
                    }
                }
            }
        }
        finally {
            $savedWhatIf3 = $WhatIfPreference
            $WhatIfPreference = $false
            Remove-PSDrive -Name $driveName -Force -ErrorAction SilentlyContinue
            $WhatIfPreference = $savedWhatIf3
        }
    }

    $preCheckMsg = if ($preCheckSkippedCount -gt 0) { " ($preCheckSkippedCount already had 2023 cert)" } else { "" }
    $actionWord = if ($WhatIfPreference) { "would delete" } else { "deleted" }
    Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "$($deletedVMs.Count) $actionWord, $failedCount failed, $skippedCount skipped${preCheckMsg}."
    return $deletedVMs.ToArray()
}

# Phase 4: Power on VMs in batches
function Start-VMs {
    param(
        [array]$VMs,
        [int]$PhaseNum,
        [int]$TotalPhases
    )

    Write-PhaseHeader -Phase $PhaseNum -TotalPhases $TotalPhases -Title "Powering on VMs ($($VMs.Count) VMs)"

    if ($VMs.Count -eq 0) {
        Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "No VMs to power on."
        return @()
    }

    # For Dry Run, just summarize how many would be powered on and return
    if ($WhatIfPreference) {
        $batchCount = [Math]::Ceiling($VMs.Count / $BatchSize)
        Write-Host "  WOULD power on $($VMs.Count) VM(s) in $batchCount batch(es) of $BatchSize." -ForegroundColor Magenta
        Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "DRY-RUN: Would power on $($VMs.Count) VM(s)."
        return $VMs
    }

    $poweredOnVMs = [System.Collections.ArrayList]::new()
    $failedCount = 0
    $totalBatches = [Math]::Ceiling($VMs.Count / $BatchSize)

    # Power on VMs in batches
    for ($b = 0; $b -lt $totalBatches; $b++) {
        $start = $b * $BatchSize
        $end = [Math]::Min($start + $BatchSize, $VMs.Count)
        $batch = @($VMs[$start..($end - 1)])
        $batchNum = $b + 1

        Write-Host ""
        Write-Host "  Batch $batchNum/$totalBatches (VMs $($start + 1)-$end of $($VMs.Count))..." -ForegroundColor White

        $savedWhatIf = $WhatIfPreference
        $WhatIfPreference = $false

        # Send start commands for this batch
        foreach ($vm in $batch) {
            Write-Log -VM $vm.Name -Message "Sending Start-VM..." -Level "INFO" -LogOnly
            try {
                Start-VM -VM $vm -Confirm:$false -RunAsync | Out-Null
            }
            catch {
                Write-Log -VM $vm.Name -Message "FAILED to send start command: $_" -Level "ERROR"
                Update-ResultVerified -VM $vm.Name -Status "Failed" -Message "NVRAM deleted but failed to power on: $_"
                $failedCount++
            }
        }

        # Poll this batch until all powered on or timeout
        $pendingNames = [System.Collections.Generic.HashSet[string]]::new()
        foreach ($vm in $batch) {
            $null = $pendingNames.Add($vm.Name)
        }

        # Remove any in this batch that already failed the start command
        $batchNames = $batch | ForEach-Object { $_.Name }
        $failedInBatch = $script:results.Details | Where-Object { $_.VMName -in $batchNames -and $_.Status -eq "Failed" }
        foreach ($f in $failedInBatch) { $null = $pendingNames.Remove($f.VMName) }

        $timeout = 120
        $elapsed = 0

        # Poll every 5 seconds until all pending VMs are powered on or timeout reached
        while ($pendingNames.Count -gt 0 -and $elapsed -lt $timeout) {
            Start-Sleep -Seconds 5
            $elapsed += 5
            $nowDone = @()
            foreach ($name in $pendingNames) {
                $currentVM = Get-VM -Name $name -ErrorAction SilentlyContinue
                if ($currentVM -and $currentVM.PowerState -eq "PoweredOn") {
                    $nowDone += $name
                }
            }

            # Update results for any VMs that are now powered on
            foreach ($name in $nowDone) {
                Write-Log -VM $name -Message "Powered on successfully." -Level "SUCCESS"
                $null = $pendingNames.Remove($name)
                $vmObj = $batch | Where-Object { $_.Name -eq $name }
                if ($vmObj) { $null = $poweredOnVMs.Add($vmObj) }
            }

            # If there are still pending VMs, log an informational message about waiting
            if ($pendingNames.Count -gt 0) {
                Write-Log -Message "Waiting for $($pendingNames.Count) VM(s) to power on... ($elapsed/${timeout}s)" -Level "INFO" -LogOnly
            }
        }

        $WhatIfPreference = $savedWhatIf

        # Handle timeouts
        foreach ($name in $pendingNames) {
            Write-Log -VM $name -Message "FAILED: Did not power on within ${timeout}s." -Level "ERROR"
            Update-ResultVerified -VM $name -Status "Failed" -Message "NVRAM deleted but VM did not power on within ${timeout}s"
            $failedCount++
        }

        Write-Host "  Batch $batchNum complete." -ForegroundColor White
    }

    Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "$($poweredOnVMs.Count) powered on, $failedCount failed."
    return $poweredOnVMs.ToArray()
}

# Phase 5: Verify 2023 cert inside each VM via Invoke-VMScript (requires VMware Tools)
function Verify-Certs {
    param(
        [array]$VMs,
        [int]$PhaseNum,
        [int]$TotalPhases
    )

    Write-PhaseHeader -Phase $PhaseNum -TotalPhases $TotalPhases -Title "Verifying Secure Boot certificates ($($VMs.Count) VMs)"

    Write-Host ""
    Write-Host "  Remotely verifying the 2023 Secure Boot certificate was added" -ForegroundColor Cyan
    Write-Host "  using VMware Tools (Invoke-VMScript)." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Requirements:" -ForegroundColor White
    Write-Host "    - VMware Tools must be installed and running inside each VM" -ForegroundColor White
    Write-Host "    - Guest credentials must have administrator privileges on the VM" -ForegroundColor White
    Write-Host ""

    if ($VMs.Count -eq 0) {
        Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "No VMs to verify."
        return
    }

    if ($WhatIfPreference) {
        Write-Host "  WOULD verify 2023 cert in $($VMs.Count) VM(s) via VMware Tools." -ForegroundColor Magenta
        Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "DRY-RUN: Would verify $($VMs.Count) VM(s)."
        return
    }

    $savedWhatIf = $WhatIfPreference
    $WhatIfPreference = $false

    $verifiedCount = 0
    $notVerifiedCount = 0
    $errorCount = 0
    $totalBatches = [Math]::Ceiling($VMs.Count / $BatchSize)

    # The script to run inside the VM for verification
    $scriptText = @'
$results = @{}

try {
    $dbBytes = (Get-SecureBootUEFI db).bytes
    $dbText = [System.Text.Encoding]::ASCII.GetString($dbBytes)
    $results["NvramHas2023Cert"] = ($dbText -match "Windows UEFI CA 2023")
} catch {
    $results["NvramHas2023Cert"] = "Error: $($_.Exception.Message)"
}

try {
    $null = mountvol S: /S 2>$null
    $sig = Get-AuthenticodeSignature "S:\EFI\Microsoft\Boot\bootmgfw.efi"
    $results["BootloaderSigner"] = $sig.SignerCertificate.Issuer
    $results["BootloaderSignerExpiry"] = $sig.SignerCertificate.NotAfter.ToString("yyyy-MM-dd")
    $null = mountvol S: /D 2>$null
} catch {
    $results["BootloaderSigner"] = "Error: $($_.Exception.Message)"
    $null = mountvol S: /D 2>$null
}

try {
    $svc = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing" -ErrorAction Stop
    $results["UEFICA2023Status"] = $svc.UEFICA2023Status
} catch {
    $results["UEFICA2023Status"] = "Error: $($_.Exception.Message)"
}

$results | ConvertTo-Json -Compress
'@

    # Process VMs in batches to avoid overwhelming the host and to provide progress feedback
    for ($b = 0; $b -lt $totalBatches; $b++) {
        $start = $b * $BatchSize
        $end = [Math]::Min($start + $BatchSize, $VMs.Count)
        $batch = @($VMs[$start..($end - 1)])
        $batchNum = $b + 1

        Write-Host ""
        Write-Host "  Batch $batchNum/$totalBatches (VMs $($start + 1)-$end of $($VMs.Count))..." -ForegroundColor White

        $pendingVMs = [System.Collections.Generic.Dictionary[string, object]]::new()
        foreach ($vm in $batch) { $pendingVMs[$vm.Name] = $vm }

        $batchTimeout = 300
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        # Poll every 10 seconds until all pending VMs have VMware Tools running or timeout reached
        while ($pendingVMs.Count -gt 0 -and $stopwatch.Elapsed.TotalSeconds -lt $batchTimeout) {
            $readyNames = @()

            # Check VMware Tools status of pending VMs
            foreach ($name in @($pendingVMs.Keys)) {
                $currentVM = Get-VM -Name $name -ErrorAction SilentlyContinue

                if ($currentVM) {
                    $toolsStatus = $currentVM.ExtensionData.Guest.ToolsRunningStatus
                    if ($toolsStatus -eq "guestToolsRunning") {
                        $readyNames += $name
                    }
                    else {
                        Write-Log -VM $name -Message "VMware Tools status: $toolsStatus ($([int]$stopwatch.Elapsed.TotalSeconds)/${batchTimeout}s)" -Level "INFO" -LogOnly
                    }
                }
            }

            # If there are ready VMs, run the verification script on them
            foreach ($name in $readyNames) {
                $vm = $pendingVMs[$name]
                Write-Log -VM $name -Message "VMware Tools ready. Running cert check..." -Level "INFO" -LogOnly

                try {
                    # Run the verification script inside the VM using Invoke-VMScript
                    $result = Invoke-VMScript -VM $vm -ScriptText $scriptText -GuestCredential $script:GuestCredential -ScriptType Powershell -ErrorAction Stop
                    $output = $result.ScriptOutput.Trim()
                    Write-Log -VM $name -Message "Invoke-VMScript raw output: $output" -Level "INFO" -LogOnly

                    $checks = $output | ConvertFrom-Json
                    $nvramOk = $checks.NvramHas2023Cert -eq $true
                    $signerInfo = $checks.BootloaderSigner
                    $signerExpiry = $checks.BootloaderSignerExpiry
                    $servicingStatus = $checks.UEFICA2023Status

                    Write-Log -VM $name -Message "NVRAM has 2023 cert: $($checks.NvramHas2023Cert)" -Level "INFO" -LogOnly
                    Write-Log -VM $name -Message "Bootloader signer: $signerInfo (expires: $signerExpiry)" -Level "INFO" -LogOnly
                    Write-Log -VM $name -Message "UEFI CA 2023 servicing status: $servicingStatus" -Level "INFO" -LogOnly
                    
                    # Determine verification result based on presence of cert in NVRAM
                    if ($nvramOk) {
                        $detail = "2023 cert in NVRAM. Bootloader signed by: $signerInfo"
                        Write-Log -VM $name -Message "VERIFIED: $detail" -Level "SUCCESS"
                        Update-ResultVerified -VM $name -Verified "Yes" -Message $detail
                        $verifiedCount++
                    }
                    else {
                        $detail = "2023 cert NOT found in NVRAM. Bootloader signed by: $signerInfo"
                        Write-Log -VM $name -Message "NOT VERIFIED: $detail" -Level "ERROR"
                        Update-ResultVerified -VM $name -Verified "No" -Message $detail
                        $notVerifiedCount++
                    }
                }
                catch {
                    Write-Log -VM $name -Message "VERIFICATION ERROR: $_" -Level "ERROR"
                    Write-Log -VM $name -Message "Full exception: $($_.Exception)" -Level "ERROR" -LogOnly
                    Update-ResultVerified -VM $name -Verified "Error" -Message "Verification failed: $_"
                    $errorCount++
                }

                $null = $pendingVMs.Remove($name)
            }

            # If there are still pending VMs, log progress and wait before next poll
            if ($pendingVMs.Count -gt 0) {
                $globalCompleted = ($b * $BatchSize) + ($batch.Count - $pendingVMs.Count)
                $pct = if ($VMs.Count -gt 0) { [Math]::Floor($globalCompleted / $VMs.Count * 100) } else { 0 }
                Write-Progress -Activity "Phase $PhaseNum/$TotalPhases : Verifying Secure Boot certificates" `
                    -Status "Batch $batchNum/$totalBatches | Pending: $($pendingVMs.Count) | Verified: $verifiedCount | Failed: $($notVerifiedCount + $errorCount)" `
                    -PercentComplete $pct
                Start-Sleep -Seconds 10
            }
        }

        # Handle batch timeouts
        foreach ($name in @($pendingVMs.Keys)) {
            Write-Log -VM $name -Message "VERIFICATION FAILED: VMware Tools not running after ${batchTimeout}s (check if VMware Tools is installed)" -Level "ERROR"
            Update-ResultVerified -VM $name -Verified "Error" -Message "VMware Tools not running after ${batchTimeout}s"
            $errorCount++
        }

        Write-Host "  Batch $batchNum complete." -ForegroundColor White
    }

    $WhatIfPreference = $savedWhatIf

    Write-Progress -Activity "Phase $PhaseNum/$TotalPhases : Verifying Secure Boot certificates" -Completed
    Write-PhaseSummary -Phase $PhaseNum -TotalPhases $TotalPhases -Summary "$verifiedCount verified, $notVerifiedCount not verified, $errorCount error(s)."
}

# =====================
# 4. Main Execution
# =====================
try {
    # Initialize the logic
    Write-Banner
    Write-LogHeader
    if ($CatalogName) {
        Initialize-CitrixModule
    }
    Initialize-VMwareConnection
    Initialize-GuestOSCredential

    # Phase 1: Get VM Details from VMware
    $totalPhases = $script:TotalPhases
    Write-PhaseHeader -Phase 1 -TotalPhases $totalPhases -Title "Getting VM details"
    if ($CatalogName) {
        $vms = @(Get-VMsFromCatalog -CatalogName $CatalogName)
    }
    else {
        $vms = @(Get-VMsFromNames -VMName $VMName)
    }
    
    # If no EFI VMs found, log and exit
    if ($vms.Count -eq 0) {
        Write-PhaseSummary -Phase 1 -TotalPhases $totalPhases -Summary "No EFI VMs found to process."
        Write-Summary
        exit 0
    }

    Write-PhaseSummary -Phase 1 -TotalPhases $totalPhases -Summary "$($vms.Count) EFI VM(s) resolved for processing."
    Write-Log -Message "Processing $($vms.Count) VM(s) in $totalPhases phase(s), batch size: $BatchSize." -Level "INFO"
    $currentPhase = 1

    # Phase 2: Maintenance mode ON
    $currentPhase++
    Set-MaintenanceMode -VMs $vms -Enable $true -PhaseNum $currentPhase -TotalPhases $totalPhases

    # Phase 3: Stop running VMs
    $currentPhase++
    $readyVMs = Stop-VMs -VMs $vms -PhaseNum $currentPhase -TotalPhases $totalPhases

    # Phase 4: Delete NVRAM files
    $currentPhase++
    $deletedVMs = @()
    if ($readyVMs -and $readyVMs.Count -gt 0) {
        $deletedVMs = Delete-NVRAM -VMs $readyVMs -PhaseNum $currentPhase -TotalPhases $totalPhases
    }
    else {
        Write-PhaseHeader -Phase $currentPhase -TotalPhases $totalPhases -Title "Deleting NVRAM files"
        Write-PhaseSummary -Phase $currentPhase -TotalPhases $totalPhases -Summary "No VMs ready for NVRAM deletion."
    }

    # Phase 5: Power on VMs (only if -PowerOnAndVerify)
    if ($PowerOnAndVerify) {
        $currentPhase++
        $poweredOnVMs = @()
        if ($deletedVMs -and $deletedVMs.Count -gt 0) {
            $poweredOnVMs = Start-VMs -VMs $deletedVMs -PhaseNum $currentPhase -TotalPhases $totalPhases
        }
        else {
            Write-PhaseHeader -Phase $currentPhase -TotalPhases $totalPhases -Title "Powering on VMs"
            Write-PhaseSummary -Phase $currentPhase -TotalPhases $totalPhases -Summary "No VMs to power on."
        }

        # Phase 6: Verify certificates (when -PowerOnAndVerify and -GuestUsername)
        if ($script:RunVerification) {
            $currentPhase++
            if ($poweredOnVMs -and $poweredOnVMs.Count -gt 0) {
                Verify-Certs -VMs $poweredOnVMs -PhaseNum $currentPhase -TotalPhases $totalPhases
            }
            else {
                Write-PhaseHeader -Phase $currentPhase -TotalPhases $totalPhases -Title "Verifying Secure Boot certificates"
                Write-PhaseSummary -Phase $currentPhase -TotalPhases $totalPhases -Summary "No VMs to verify."
            }
        }
    }

    # Phase 7: Maintenance mode OFF
    $currentPhase++
    Set-MaintenanceMode -VMs $vms -Enable $false -PhaseNum $currentPhase -TotalPhases $totalPhases
    $script:maintenanceCleared = $true
}
catch {
    Write-Log -Message "SCRIPT ERROR: $_" -Level "ERROR"
    Write-Log -Message "Full exception: $($_.Exception)" -Level "ERROR" -LogOnly
}
finally {
    # Safety net: clear maintenance mode if the try block didn't reach Phase 7
    if (-not $script:maintenanceCleared -and $vms -and $vms.Count -gt 0 -and $CatalogName) {
        Write-Log -Message "Clearing maintenance mode in cleanup (script did not complete normally)..." -Level "WARN"
        try {
            $savedEAP = $ErrorActionPreference
            $ErrorActionPreference = "Continue"
            foreach ($vm in $vms) {
                $brokerMachine = Get-BrokerMachine -HostedMachineName $vm.Name -ErrorAction SilentlyContinue
                if ($brokerMachine -and $brokerMachine.InMaintenanceMode) {
                    Set-BrokerMachine -InputObject $brokerMachine -InMaintenanceMode $false
                    Write-Log -VM $vm.Name -Message "Maintenance mode cleared in cleanup." -Level "WARN"
                }
            }
        }
        catch {
            Write-Log -Message "WARNING: Failed to clear maintenance mode in cleanup: $_" -Level "ERROR"
            Write-Log -Message "Manual recovery: Run Set-BrokerMachine -MachineName <name> -InMaintenanceMode `$false for each VM." -Level "ERROR"
        }
        finally {
            $ErrorActionPreference = $savedEAP
        }
    }

    Write-Summary
    $savedWhatIf = $WhatIfPreference
    $WhatIfPreference = $false
    if ($null -ne $script:savedCertAction) {
        try { Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction $script:savedCertAction -Confirm:$false | Out-Null } catch { }
    }
    try { Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction SilentlyContinue } catch { }
    $WhatIfPreference = $savedWhatIf
    Write-Log -Message "Disconnected from vCenter." -Level "INFO" -LogOnly
    Write-Log -Message "Script completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')." -Level "INFO" -LogOnly
}
