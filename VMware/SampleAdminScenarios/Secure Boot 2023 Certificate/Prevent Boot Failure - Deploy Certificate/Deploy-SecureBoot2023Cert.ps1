<#
.SYNOPSIS
    Prevent boot failure on ESXi 8.0.0 VMs after ESXi 8.0.3 catalog update
    by deploying the Windows UEFI CA 2023 Secure Boot certificate via Microsoft servicing.
.DESCRIPTION
    1. Problem:
       VMs originally created on ESXi 8.0.0 only have the Windows UEFI CA 2011 certificate in their Secure Boot database. 
       After the ESXi host is upgraded to 8.0.3, an MCS catalog update applies a 2023-signed bootloader to these VMs. 
       The VMs fail to boot with "No Boot Media" because their Secure Boot DB does not trust the 2023 certificate.

    2. Preventive Solution Steps:
       Step 1 - Check if the 2023 cert is already in Secure Boot DB. If present, exit.
       Step 2 - If servicing data (cert payload delivered by Windows Update) is missing,
                trigger Windows Update to install the required cumulative update
                (July 2025+) and exit. After update + reboot, next run proceeds to Step 3.
       Step 3 - Set regkey AvailableUpdates=0x5944 and trigger the Secure-Boot-Update
                scheduled task. The cert is written to Secure Boot DB on next reboot.

    3. Important Notes:
       (1) Multiple reboots are required to complete the full deployment:
             Boot 1: Step 2 triggers Windows Update to download servicing data
             Boot 2: Step 3 deploys the cert (applied on next reboot)
             Boot 3: Step 1 confirms cert is present (done)
       (2) This script covers the minimum functions to prevent the boot failure.
           For fuller information on Secure Boot certificate updates, please refer to:
           https://support.microsoft.com/en-us/topic/sample-secure-boot-inventory-data-collection-script-d02971d2-d4b5-42c9-b58a-8527f0ffa30b
           https://support.microsoft.com/en-us/topic/kb5025885
.NOTES
    Version   : 2.0
    Author    : Citrix Systems, Inc.
.EXAMPLE
    # Run directly (elevated PowerShell):
    .\Deploy-SecureBoot2023Cert.ps1

    # Deploy via GPO Immediate Scheduled Task:
    # 1. Open gpmc.msc
    # 2. Create/edit a GPO linked to the OU containing target VDAs
    # 3. Computer Configuration > Preferences > Control Panel Settings > Scheduled Tasks
    # 4. New > Immediate Task (At least Windows 7)
    #    - Run as: NT AUTHORITY\SYSTEM
    #    - Check "Run with highest privileges"
    #    - Action: Start a program
    #      Program:   powershell.exe
    #      Arguments: -ExecutionPolicy Bypass -File "\\domain\SYSVOL\...\Deploy-SecureBoot2023Cert.ps1"
#>

# /*************************************************************************
# * Copyright (c) 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Step 1: If 2023 cert already present, no action needed.
try {
    $dbBytes = (Get-SecureBootUEFI db).Bytes
    $hasCert = ([System.Text.Encoding]::ASCII.GetString($dbBytes)) -match "Windows UEFI CA 2023"
    if ($hasCert) {
        Write-Host "2023 certificate already present. No action needed."
        exit 0
    }
}
catch {
    Write-Host "Cannot read Secure Boot DB: $_ (Is Secure Boot enabled? Running as admin?)"
    exit 1
}

Write-Host "2023 certificate NOT present. Attempting deployment."

# Check servicing data for cert deployment (2023 cert, service mechanism, and Secure-Boot-Update task).
$servicingReady = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing"
$taskExists     = Get-ScheduledTask -TaskPath "\Microsoft\Windows\PI\" -TaskName "Secure-Boot-Update" -ErrorAction SilentlyContinue

# Step 2:
#   If servicing data not available, trigger Windows Update to install the required cumulative update (July 2025+).
#   After update + reboot, next run will proceed to Step 3.
# Note:
#   1. -Wait waits for usoclient.exe to exit, not for the actual update to finish.
#      The real download/install is async in the Update Orchestrator service.
#   2. Via GPO Scheduled Task, this runs in the background and does not delay user login.
#   3. To check the progress, manually open Settings > Windows Update > Check for updates.
#   4. usoclient may fail silently depending on enterprise restrictions (WSUS/SCCM/Intune).
#      If usoclient failed, manually trigger Windows Update or install the latest cumulative update.
#   5. A reboot is required after the update installs to complete the installation.
if (-not $servicingReady -or -not $taskExists) {
    try {
        Start-Process "usoclient.exe" -ArgumentList "StartScan"   -Wait -NoNewWindow
        Start-Process "usoclient.exe" -ArgumentList "StartInstall" -Wait -NoNewWindow
    }
    catch {
        Write-Host "Failed to trigger Windows Update: $_"
    }
    exit 0
}

# Step 3: Servicing data and task are both available. Deploy the 2023 cert.
#   Sets AvailableUpdates to 0x5944 (KB5025885: bit mask for deploying the Windows UEFI CA 2023
#   certificate to the Secure Boot DB), then triggers the Secure-Boot-Update task.
#   The cert is written to Secure Boot DB on next reboot.
try {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Secureboot" `
                     -Name "AvailableUpdates" -Value 0x5944 -Type DWord -Force
    Start-ScheduledTask -TaskName "\Microsoft\Windows\PI\Secure-Boot-Update"
    Write-Host "Cert deployment initiated (regkey 0x5944 + task triggered). Reboot required."
}
catch {
    Write-Host "Deployment failed: $_"
    exit 1
}
exit 0
