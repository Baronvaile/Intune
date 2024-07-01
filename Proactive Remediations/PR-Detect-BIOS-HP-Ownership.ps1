Function Get-BIOSSetting
{
    param(
        [parameter(Mandatory=$true, HelpMessage="Setting")]
        [ValidateNotNullOrEmpty()]
        [string]$Setting
    )
 
    $BIOS = Get-WmiObject -class hp_biossetting -Namespace "root\hp\instrumentedbios"
    $BIOSSetting = $BIOS | Where-Object {$_.Name -eq $Setting} | Format-Table Name, Value
    
    $a = $BIOSSetting | Out-String
    $b = $a -replace '\s+',' '
 
    $result = $b.Contains('AFNI, Inc.')
    Write-Output $result
}
 
$computerModel = (Get-WmiObject Win32_ComputerSystem).Model
if ($computerModel.Contains('G2')) {
    $setting = "Ownership Tag"
}
elseif ($computerModel.Contains('G3')) {
    $setting = "Ownership Tag"
}
 
$obj = Get-BIOSSetting -Setting $setting
Write-Output $obj