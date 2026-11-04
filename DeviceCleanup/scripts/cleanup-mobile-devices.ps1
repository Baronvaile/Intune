<#
.SYNOPSIS
    Removes stale mobile devices from Microsoft Intune.

.DESCRIPTION
    This script uses Get-StaleMobileDevices to identify stale iOS and Android devices,
    then removes them from Intune.

    Intended to be run AFTER devices have been disabled in Entra.

.PARAMETER DryRun
    When $true, no changes are made. Actions are only displayed.

.PARAMETER Force
    Bypasses confirmation prompt. Required for non-interactive execution (e.g., Azure Automation).

.INPUTS
    None

.OUTPUTS
    CSV report of processed devices

.NOTES
    Author: Aaron Sharp (MDM Team)
    Version: 1.0

.EXAMPLE
    Dry run (safe mode)
    .\remove-mobile-devices.ps1 -DryRun $true

.EXAMPLE
    Execute removal
    .\remove-mobile-devices.ps1 -DryRun $false

.EXAMPLE
    Execute removal non-interactively (automation)
    .\remove-mobile-devices.ps1 -DryRun $false -Force $true
#>

param(
    [bool]$DryRun = $true,
    [bool]$Force = $false,
    [bool]$UseManagedIdentity = $false
)

Write-Host ""
Write-Host "Usage:"
Write-Host "  .\remove-mobile-devices.ps1 -DryRun `$true   (safe test)"
Write-Host "  .\remove-mobile-devices.ps1 -DryRun `$false  (execute)"
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
            Connect-MgGraph -Identity
        }
        else {
            Connect-MgGraph -Scopes `
            "Device.ReadWrite.All",
            "DeviceManagementManagedDevices.ReadWrite.All"
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


# Load discovery function
. "$PSScriptRoot\get-stale-mobile-devices.ps1"

# Ensure folders exist
$logDir = "$PSScriptRoot\..\logs"
$reportDir = "$PSScriptRoot\..\reports"

New-Item -Path $logDir -ItemType Directory -Force | Out-Null
New-Item -Path $reportDir -ItemType Directory -Force | Out-Null

# Start logging
$logFile = "$logDir\remove-run-$(Get-Date -Format yyyyMMdd-HHmm).log"
Start-Transcript -Path $logFile

Write-Host "========================================="
Write-Host " Mobile Device Removal Script Starting"
Write-Host "========================================="
Write-Host "DryRun mode: $DryRun"
Write-Host ""

# Get stale devices
Write-Host "Running stale device discovery..."
$results = Get-StaleMobileDevices -Silent $true -ExportCsv $false

Write-Host "Devices identified: $($results.Count)"

# Exit early if nothing found
if ($results.Count -eq 0) {
    Write-Host "No stale devices found. Exiting."
    Stop-Transcript
    return
}

# SAFETY THRESHOLD
$maxDevices = 1000

if ($results.Count -gt $maxDevices) {
    Write-Host "Too many devices selected ($($results.Count)). Aborting." -ForegroundColor Red
    Stop-Transcript
    throw "Safety threshold exceeded"
}

# Confirmation (interactive only)
if (-not $DryRun -and -not $Force -and -not $UseManagedIdentity) {

    Write-Host ""
    Write-Host "WARNING: You are about to REMOVE $($results.Count) devices from Intune." -ForegroundColor Yellow
    $confirm = Read-Host "Type YES to continue"

    if ($confirm -ne "YES") {
        Write-Host "Operation cancelled."
        Stop-Transcript
        return
    }
}

# Track actions
$actionResults = @()

# Process devices
foreach ($device in $results) {

    # Skip devices that are still enabled (optional safety)
    if ($device.EntraEnabled -eq $true) {
        Write-Host "Skipping enabled device: $($device.DeviceName)"
        
        $actionResults += [PSCustomObject]@{
            DeviceName = $device.DeviceName
            Action     = "Skipped (Still Enabled)"
        }

        continue
    }

    if ($DryRun) {
        Write-Host "[DRY RUN] Would remove from Intune: $($device.DeviceName)"

        $actionResults += [PSCustomObject]@{
            DeviceName = $device.DeviceName
            Action     = "Would Remove"
        }
    }
    else {
        try {
            Write-Host "Removing from Intune: $($device.DeviceName)"

            Remove-MgDeviceManagementManagedDevice -ManagedDeviceId $device.IntuneDeviceId

            $actionResults += [PSCustomObject]@{
                DeviceName = $device.DeviceName
                Action     = "Removed"
            }
        }
        catch {
            Write-Host "ERROR removing $($device.DeviceName): $_" -ForegroundColor Red

            $actionResults += [PSCustomObject]@{
                DeviceName = $device.DeviceName
                Action     = "Error"
            }
        }
    }
}

# Summary
$removedCount = ($actionResults | Where-Object { $_.Action -eq "Removed" }).Count
$skippedCount = ($actionResults | Where-Object { $_.Action -like "Skipped*" }).Count

Write-Host ""
Write-Host "Removed: $removedCount"
Write-Host "Skipped: $skippedCount"

# Export report
$reportFile = "$reportDir\removed-devices-$(Get-Date -Format yyyyMMdd-HHmm).csv"
$actionResults | Export-Csv $reportFile -NoTypeInformation

Write-Host ""
Write-Host "========================================="
Write-Host " Completed"
Write-Host "========================================="
Write-Host "Devices processed: $($results.Count)"
Write-Host "Report saved to: $reportFile"

# Stop logging
Stop-Transcript