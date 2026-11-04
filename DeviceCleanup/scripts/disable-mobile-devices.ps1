<#
.SYNOPSIS
    Disables stale mobile devices in Microsoft Entra ID.

.DESCRIPTION
    This script calls Get-StaleMobileDevices to identify stale iOS and Android devices,
    then disables them in Entra ID.

    Supports DryRun mode for safe testing and includes logging, reporting, and safety thresholds.

.PARAMETER DryRun
    When $true, no changes are made. Actions are only displayed.

    Default: $true (safe mode)

.INPUTS
    None

.OUTPUTS
    CSV report of processed devices

.NOTES
    Author: Aaron Sharp (MDM Team)
    Version: 1.1

.EXAMPLE
    Dry run (safe mode, no changes made)
    .\disable-mobile-devices.ps1 -DryRun $true

.EXAMPLE
    Execute device disable actions
    .\disable-mobile-devices.ps1 -DryRun $false

.EXAMPLE
    Typical workflow:
    1. Run discovery script to review devices
    2. Run disable script in DryRun mode
    3. Validate results
    4. Run with DryRun $false to enforce changes
#>


param(
    [bool]$DryRun = $true,
    [bool]$UseManagedIdentity = $false
)

if ($PSBoundParameters.Count -eq 0) {
    Write-Host "Usage:"
    Write-Host "  .\disable-mobile-devices.ps1 -DryRun `$true   (safe test)"
    Write-Host "  .\disable-mobile-devices.ps1 -DryRun `$false  (execute)"
    Write-Host ""
}
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
            "Device.ReadWrite.All",
            "DeviceManagementManagedDevices.Read.All"
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
$logFile = "$logDir\disable-run-$(Get-Date -Format yyyyMMdd-HHmm).log"
Start-Transcript -Path $logFile

Write-Host "========================================="
Write-Host " Mobile Device Disable Script Starting"
Write-Host "========================================="
Write-Host "DryRun mode: $DryRun"
Write-Host ""

# Get stale devices (reuse your discovery logic)
Write-Host "Running stale device discovery..."

$results = Get-StaleMobileDevices -Silent $true -ExportCsv $false

Write-Host "Devices identified: $($results.Count)"
if ($results.Count -eq 0) {
    Write-Host "No stale devices found. Exiting."
    Stop-Transcript
    return
}


# SAFETY THRESHOLD (adjust as needed)
$maxDevices = 1000

if ($results.Count -gt $maxDevices) {
    Write-Host "Too many devices selected ($($results.Count)). Aborting." -ForegroundColor Red
    Stop-Transcript
    throw "Safety threshold exceeded"
}

#  CONFIRMATION BLOCK
if (-not $DryRun -and -not $UseManagedIdentity) {
    Write-Host ""
    Write-Host "WARNING: You are about to disable $($results.Count) devices." -ForegroundColor Yellow
    $confirm = Read-Host "Type YES to continue"

    if ($confirm -ne "YES") {
        Write-Host "Operation cancelled."
        Stop-Transcript
        return
    }
}

# Process devices
foreach ($device in $results) {

    # Skip if already disabled (important)
    if ($device.EntraEnabled -eq $false) {
        Write-Host "Skipping already disabled device: $($device.DeviceName)"
        continue
    }

    if ($DryRun) {
        Write-Host "[DRY RUN] Would disable: $($device.DeviceName)"
    }
    else {
        try {
            Write-Host "Disabling: $($device.DeviceName)"

            Update-MgDevice -DeviceId $device.EntraObjectId -AccountEnabled:$false
        }
        catch {
            Write-Host "ERROR disabling $($device.DeviceName): $_" -ForegroundColor Red
        }
    }
}

# Export report
$reportFile = "$reportDir\disabled-devices-$(Get-Date -Format yyyyMMdd-HHmm).csv"
$results | Export-Csv $reportFile -NoTypeInformation

Write-Host ""
Write-Host "========================================="
Write-Host " Completed"
Write-Host "========================================="
Write-Host "Devices processed: $($results.Count)"
Write-Host "Report saved to: $reportFile"

# Stop logging
Stop-Transcript