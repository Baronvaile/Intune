<#
.SYNOPSIS
    Configuration settings for device cleanup scripts.

.DESCRIPTION
    This file contains configuration values used by device lifecycle scripts,
    including filtering criteria, thresholds, and exclusions.

    Modify values here instead of changing script logic.

.NOTES
    Author: Aaron Sharp (MDM Team)
    Version: 1.0
#>
# config/settings.ps1

$Global:CutoffDays = 730

# NOTE:
# These OS lists are used directly for filtering.
# If left empty, scripts may process ALL devices.

# Supported OperatingSystem values (from Intune / Graph):
# - iOS
# - iPadOS
# - Android
# - AndroidEnterprise
# - Windows
# - macOS
# - Linux
# - ChromeOS (if applicable in tenant)

# Mobile device OS types (used by MDM scripts)
$Global:MobileOS = @(
    "iOS",
    "iPadOS",
    "Android",
    "AndroidEnterprise"
)

$Global:EndpointOS = @(
    "Windows",
    "macOS"
)

# Future use (not currently used)
# $Global:WindowsOS = @("Windows")
# $Global:MacOS = @("macOS")


$Global:MobileExcludeOwnerType = @("personal")
$Global:EndpointExcludeOwnerType = @()