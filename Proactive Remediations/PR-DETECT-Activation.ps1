#Get-CimInstance -ClassName SoftwareLicensingProduct -ComputerName $CN |`
#     Where-Object {$_.PartialProductKey -and $_.Name -like "*Windows*"} | Select-Object `
#    @{Expression={$_.PSComputerName};Name="ComputerName"},
#    @{Expression={$LicenseStatus[$($_.LicenseStatus)]};Name="LicenseStatus"}

#Get-CimInstance -ClassName SoftwareLicensingProduct |`
#   Where-Object {$_.PartialProductKey -and $_.Name -like "*Windows*"} | Select-Object `
#  @{Expression={$LicenseStatus[$($_.LicenseStatus)]};Name="LicenseStatus"}


    # This scripts gets Windows License and Activation status

#$ErrorActionPreference = "silentlycontinue";
#$ActivationNumber = 3 # if the command below fails, we set this variable to "critical". Otherwise the variable is later filled with the proper values (0 = ok, 1 = down, 2 = warning, 3 = critical)

 $ActivationStatus = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey } | Select-Object LicenseStatus       
 $LicenseStatus = $ActivationStatus.LicenseStatus

 #       $LicenseResult = switch($LicenseStatus){
 #         0	{"Unlicensed"}
 #         1	{"Licensed"}
 #         2	{"OOBGrace"}
 #         3	{"OOTGrace"}
 #         4	{"NonGenuineGrace"}
 #         5	{"Not Activated"}
 #         6	{"ExtendedGrace"}
 #         default {"unknown"}
 #       }
        
 #       $ActivationNumber = switch($LicenseStatus){
 #         0	{3}
 #         1	{0}
 #         2	{2}
 #         3	{2}
 #         4	{3}
 #         5	{3}
 #         6	{2}
 #         default {3}     
 #       }   
        
 #write-host "Message.ATSWindowsActivation: $LicenseResult"
 #Write-Host "Statistic.ATSWindowsActivation: $ActivationNumber"
 # Exit $ActivationNumber;

 if ($LicenseStatus = 1) {
    Exit 0}
    
    else {Exit 1}