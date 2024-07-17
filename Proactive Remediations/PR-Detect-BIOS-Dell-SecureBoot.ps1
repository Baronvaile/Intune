#Dell BIOS/UEFI setting Detection script

$setting = "SecureBoot"

function Get-BIOSSetting
{
    param(
        [parameter(Mandatory=$TRUE, HelpMessage="Setting")]
        [ValidateNotNullOrEmpty()]
        [string]$Setting
    )
 
    $BIOS = Get-WmiObject -class EnumerationAttribute -Namespace "root\dcim\sysman\biosattributes"
    $BIOSSetting = $BIOS | Where-Object {$_.AttributeName -eq $Setting} | Format-Table AttributeName,CurrentValue
    
    $a = $BIOSSetting | Out-String
    $b = $a -replace '\s+',' '
 
    $result = $b.Contains('Enabled')
    Write-Output $result
}
 
 
$obj = Get-BIOSSetting -Setting $setting
Write-Output $obj

If ($obj -eq $true){
    Write-Output "Compliant"
    Exit 0
}
else { 
Write-Warning "Not Compliant"
Exit 1}