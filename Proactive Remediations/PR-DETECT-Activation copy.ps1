 $ActivationStatus = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey } | Select-Object LicenseStatus       
 $LicenseStatus = $ActivationStatus.LicenseStatus

 
 #write-host "Message.ATSWindowsActivation: $LicenseResult"
 #Write-Host "Statistic.ATSWindowsActivation: $ActivationNumber"
 # Exit $ActivationNumber;
Try {
    if ($LicenseStatus = 1) {exit 0}
    else {exit 1}
}Catch{ Exit 2000}
 