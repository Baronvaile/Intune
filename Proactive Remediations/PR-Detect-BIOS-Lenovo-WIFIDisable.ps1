function Get-BIOSSetting
{
    param(
        [parameter(Mandatory=$TRUE, HelpMessage="Setting")]
        [ValidateNotNullOrEmpty()]
        [string]$Setting
    )
 
$BIOS = Get-WmiObject -class Lenovo_BiosSetting -Namespace "root\wmi"
$BIOSSetting = $BIOS | Where-Object {$_.CurrentSetting -like $Setting} | Format-Table CurrentSetting,IsSet

   $a = $BIOSSetting | Out-String
#   $b = $a -replace '\s+',' '
 
    $result = $a.Contains("Wireless LAN,Disabled")
    Write-Output $result
}
 
$Setting = "*Wireless LAN*"

$obj = Get-BIOSSetting -Setting $Setting
Write-Output $obj