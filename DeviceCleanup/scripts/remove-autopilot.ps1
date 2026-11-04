<#
.SYNOPSIS
    Removes stale Windows Autopilot device records.

.DESCRIPTION
    This script identifies Autopilot devices that are associated with stale or disabled
    Entra devices and removes their Autopilot records.

    Intended for environments where Autopilot is not actively used and contains
    stale or unused device records.

.PARAMETER DryRun
    When $true, no changes are made. Actions are only displayed.

.PARAMETER Force
    Bypasses confirmation prompt. Required for non-interactive execution (e.g., Azure Automation).

.INPUTS
    None

.OUTPUTS
    CSV report of processed Autopilot devices

.NOTES
    Author: Aaron Sharp (MDM Team)
    Version: 1.0

.EXAMPLE
    Dry run
    .\remove-autopilot.ps1 -DryRun $true

.EXAMPLE
    Execute removal
    .\remove-autopilot.ps1 -DryRun $false

.EXAMPLE
    Automation execution
    .\remove-autopilot.ps1 -DryRun $false -Force $true
#>

param(
    [bool]$DryRun = $true,
    [bool]$Force = $false,
    [bool]$UseManagedIdentity = $false
)

Write-Host ""
Write-Host "Usage:"
Write-Host "  .\remove-autopilot.ps1 -DryRun `$true   (safe test)"
Write-Host "  .\remove-autopilot.ps1 -DryRun `$false  (execute)"
Write-Host ""

# Load config
. "$PSScriptRoot\..\config\settings.ps1"

# Verify Microsoft Graph module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "Microsoft Graph PowerShell SDK is not installed." -ForegroundColor Red
    Write-Host "Install it using: Install-Module Microsoft.Graph -Scope CurrentUser"
    throw "Missing Microsoft Graph module"
}

# Import module
Import-Module Microsoft.Graph

# Verify connection to Graph

$context = Get-MgContext

if (-not $context -or -not $context.Account) {
    Write-Host "Not connected to Microsoft Graph. Attempting login..."

    try {
        if ($UseManagedIdentity) {
            # Azure Automation mode
            Connect-MgGraph -Identity
        }
        else {
            # Local / interactive mode
            Connect-MgGraph -Scopes `
            "Device.Read.All",
            "Device.ReadWrite.All",
            "DeviceManagementManagedDevices.Read.All",
            "DeviceManagementServiceConfig.ReadWrite.All"
        }

        Write-Host "Connected to Microsoft Graph as: $((Get-MgContext).Account)"
    }
    catch {
        Write-Host "Failed to connect to Microsoft Graph." -ForegroundColor Red
        throw
    }
}
else {
    Write-Host "Reusing existing Graph connection: $($context.Account)"
}


# Ensure folders exist
$logDir = "$PSScriptRoot\..\logs"
$reportDir = "$PSScriptRoot\..\reports"

New-Item -Path $logDir -ItemType Directory -Force | Out-Null
New-Item -Path $reportDir -ItemType Directory -Force | Out-Null

# Start logging
$logFile = "$logDir\autopilot-remove-$(Get-Date -Format yyyyMMdd-HHmm).log"
Start-Transcript -Path $logFile

Write-Host "========================================="
Write-Host " Autopilot Cleanup Script Starting"
Write-Host "========================================="
Write-Host "DryRun mode: $DryRun"
Write-Host ""


# Load Entra devices for comparison
Write-Host "Loading Entra devices..."
$entraDevices = Get-MgDevice -All | Group-Object deviceId -AsHashTable

# Load Autopilot devices
Write-Host "Loading Autopilot devices..."
$autopilotDevices = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -All

Write-Host "Autopilot devices found: $($autopilotDevices.Count)"
if ($autopilotDevices.Count -eq 0) {
    Write-Host "No Autopilot devices found. Exiting."
    Stop-Transcript
    return
}

# SAFETY THRESHOLD
$maxDevices = 5000

if ($autopilotDevices.Count -gt $maxDevices) {
    Write-Host "Too many Autopilot devices ($($autopilotDevices.Count)). Aborting." -ForegroundColor Red
    Stop-Transcript
    throw "Safety threshold exceeded"
}

# Confirmation
if (-not $DryRun -and -not $Force -and -not $UseManagedIdentity) {
    Write-Host ""
    Write-Host "WARNING: You are about to REMOVE Autopilot records." -ForegroundColor Yellow
    $confirm = Read-Host "Type YES to continue"

    if ($confirm -ne "YES") {
        Write-Host "Operation cancelled."
        Stop-Transcript
        return
    }
}

# Track actions
$actionResults = @()

foreach ($apDevice in $autopilotDevices) {

    $aadId = $apDevice.AzureActiveDirectoryDeviceId

    if ([string]::IsNullOrEmpty($aadId)) {
        continue
    }

    # Check if device exists in Entra
    if (-not $entraDevices.ContainsKey($aadId)) {

        if ($DryRun) {
            Write-Host "[DRY RUN] Would remove orphan Autopilot device: $($apDevice.DisplayName)"

            $actionResults += [PSCustomObject]@{
                DeviceName = $apDevice.DisplayName
                Action     = "Would Remove (Orphan)"
            }
        }
        else {
            try {
                Write-Host "Removing orphan Autopilot device: $($apDevice.DisplayName)"

                Remove-MgDeviceManagementWindowsAutopilotDeviceIdentity `
                    -WindowsAutopilotDeviceIdentityId $apDevice.Id

                $actionResults += [PSCustomObject]@{
                    DeviceName = $apDevice.DisplayName
                    Action     = "Removed (Orphan)"
                }
            }
            catch {
                Write-Host "ERROR removing $($apDevice.DisplayName): $_" -ForegroundColor Red
            }
        }

        continue
    }

    $entra = $entraDevices[$aadId]

    # Only remove if Entra device is disabled
    if ($entra.AccountEnabled -eq $false) {

        if ($DryRun) {
            Write-Host "[DRY RUN] Would remove Autopilot device: $($apDevice.DisplayName)"

            $actionResults += [PSCustomObject]@{
                DeviceName = $apDevice.DisplayName
                Action     = "Would Remove (Disabled Device)"
            }
        }
        else {
            try {
                Write-Host "Removing Autopilot device: $($apDevice.DisplayName)"

                Remove-MgDeviceManagementWindowsAutopilotDeviceIdentity `
                    -WindowsAutopilotDeviceIdentityId $apDevice.Id

                $actionResults += [PSCustomObject]@{
                    DeviceName = $apDevice.DisplayName
                    Action     = "Removed"
                }
            }
            catch {
                Write-Host "ERROR removing $($apDevice.DisplayName): $_" -ForegroundColor Red
            }
        }
    }
    else {
        # Skip active devices
        $actionResults += [PSCustomObject]@{
            DeviceName = $apDevice.DisplayName
            Action     = "Skipped (Active Device)"
        }
    }
}

# Export report
$reportFile = "$reportDir\autopilot-cleanup-$(Get-Date -Format yyyyMMdd-HHmm).csv"
$actionResults | Export-Csv $reportFile -NoTypeInformation

Write-Host ""
Write-Host "========================================="
Write-Host " Completed"
Write-Host "========================================="
Write-Host "Report saved to: $reportFile"

$removed = ($actionResults | Where-Object { $_.Action -like "Removed*" }).Count
$skipped = ($actionResults | Where-Object { $_.Action -like "Skipped*" }).Count

Write-Host "Removed: $removed"
Write-Host "Skipped: $skipped"

# Stop logging
Stop-Transcript