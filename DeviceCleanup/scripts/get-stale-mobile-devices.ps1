<#
.SYNOPSIS
    Identifies stale mobile devices (iOS and Android) in Intune and Entra ID.

.DESCRIPTION
    This script retrieves mobile devices from Microsoft Intune and correlates them
    with Microsoft Entra ID device records using the AzureADDeviceId / deviceId mapping.

    A device is considered stale if:
    - The Intune last sync date is older than the configured cutoff
    - The Entra last sign-in date is older than the configured cutoff

    The script outputs results to a CSV report for validation and review.
    No changes are made to devices (read-only).

.PARAMETER Silent
    Suppresses console output when called from another script.

.PARAMETER ExportCsv
    Controls whether a CSV file is generated.

.PARAMETER UseConfig
    When set to $true, loads configuration values from /config/settings.ps1.

.NOTES
    Author: Aaron Sharp (MDM Team)
    Version: 1.1

    .EXAMPLE
    Run script normally (displays output and exports CSV)
    .\get-stale-mobile-devices.ps1

.EXAMPLE
    Call from another script (no console output, no CSV export)
    Get-StaleMobileDevices -Silent $true -ExportCsv $false

.EXAMPLE
    Run silently but still export CSV
    Get-StaleMobileDevices -Silent $true -ExportCsv $true
#>

function Get-StaleMobileDevices {

    param(
        [bool]$Silent = $false,
        [bool]$ExportCsv = $true,
        [bool]$UseConfig = $true,
        [bool]$UseManagedIdentity = $false
    )

    # Load config
    if ($UseConfig) {
        . "$PSScriptRoot\..\config\settings.ps1"
    }

 
    # Use config values
    $cutoff = (Get-Date).AddDays(-$Global:CutoffDays)

    if (-not $Silent) {
        Write-Host "Cutoff date: $cutoff"
        Write-Host "Loading Entra devices..."
    }

    # Load Entra devices
    $entraDevices = Get-MgDevice -All | Group-Object -Property deviceId -AsHashTable

    if (-not $Silent) {
        Write-Host "Loading Intune mobile devices..."
    }

    # Load Intune devices (filtered)
    $devices = Get-MgDeviceManagementManagedDevice -All | Where-Object {
        $_.OperatingSystem -in $Global:MobileOS -and
        $_.ManagedDeviceOwnerType -notin $Global:ExcludeOwnerType
    }

    $results = @()

    foreach ($device in $devices) {

        if ([string]::IsNullOrEmpty($device.AzureADDeviceId)) { continue }

        if (-not $entraDevices.ContainsKey($device.AzureADDeviceId)) { continue }

        $entra = $entraDevices[$device.AzureADDeviceId]

        $lastSync = $device.lastSyncDateTime
        $lastSignIn = $entra.ApproximateLastSignInDateTime

        if (
            $lastSync -lt $cutoff -and
            $lastSignIn -lt $cutoff
        ) {
            $results += [PSCustomObject]@{
                DeviceName      = $device.DeviceName
                OS              = $device.OperatingSystem
                OwnerType       = $device.ManagedDeviceOwnerType
                LastSync        = $lastSync
                LastSignIn      = $lastSignIn
                Compliance      = $device.ComplianceState
                EntraEnabled    = $entra.AccountEnabled
                IntuneDeviceId  = $device.Id
                EntraObjectId   = $entra.Id
            }
        }
    }

    if (-not $Silent) {
        Write-Host "`nStale devices found: $($results.Count)"
        $results | Format-Table DeviceName, OS, LastSync, LastSignIn
    }

    # Export CSV if requested
    if ($ExportCsv) {
        $reportPath = "$PSScriptRoot\..\reports\stale-mobile-devices.csv"
        New-Item -Path (Split-Path $reportPath) -ItemType Directory -Force | Out-Null
        $results | Export-Csv $reportPath -NoTypeInformation
    }

    return $results
}

# ✅ Allow script to run standalone OR be imported
if ($MyInvocation.InvocationName -ne '.') {
    Get-StaleMobileDevices
}