<#
.SYNOPSIS
    Test run script for device cleanup workflow.

.DESCRIPTION
    Executes discovery logic and provides a summary of devices that would be
    disabled or removed, without making any changes.

.NOTES
    Author: Aaron Sharp
    Version: 1.0
#>

# Load config
. "$PSScriptRoot\..\config\settings.ps1"

# Load discovery function
. "$PSScriptRoot\..\scripts\get-stale-mobile-devices.ps1"

Write-Host "========================================="
Write-Host " Device Cleanup TEST RUN"
Write-Host "========================================="
Write-Host ""

# Run discovery
$results = Get-StaleMobileDevices -Silent $true -ExportCsv $false

if ($results.Count -eq 0) {
    Write-Host "No stale devices found."
    return
}

# Summary counts
$total = $results.Count
$disabled = ($results | Where-Object { $_.EntraEnabled -eq $false }).Count
$enabled = ($results | Where-Object { $_.EntraEnabled -eq $true }).Count

# OS breakdown
$osBreakdown = $results | Group-Object OS | Sort-Object Count -Descending

Write-Host "SUMMARY"
Write-Host "-------"
Write-Host "Total stale devices: $total"
Write-Host "Enabled devices:     $enabled"
Write-Host "Already disabled:    $disabled"
Write-Host ""

Write-Host "OS Breakdown:"
foreach ($group in $osBreakdown) {
    Write-Host "  $($group.Name): $($group.Count)"
}

Write-Host ""
Write-Host "Sample devices:"
$results | Select-Object -First 10 DeviceName, OS, LastSync, LastSignIn | Format-Table

Write-Host ""
Write-Host "NOTE: No actions were performed (safe test run)."
Write-Host "========================================="
