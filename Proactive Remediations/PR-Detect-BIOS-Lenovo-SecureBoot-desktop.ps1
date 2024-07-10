#gwmi -class Lenovo_BiosSetting -namespace root\wmi | Where-Object {$_.CurrentSetting.split(",",[StringSplitOptions]::RemoveEmptyEntries) -eq "SecureBoot"} | Format-List CurrentSetting
#gwmi -class Lenovo_BiosSetting -namespace root\wmi | ForEach-Object {if ($_.CurrentSetting -ne "") {Write-Host $_.CurrentSetting.replace(","," = ")}}

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
 
    $result = $a.Contains("SecureBoot,Enable")
    Write-Output $result
}
 
$Setting = "*Secure Boot*"

$obj = Get-BIOSSetting -Setting $Setting
Write-Output $obj
If ($obj -eq $true){
    Write-Output "Compliant"
    Exit 0
}
else { 
Write-Warning "Not Compliant"
Exit 1}
