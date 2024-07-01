function Set-BIOSSetting {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$Setting,
        [Parameter(Mandatory=$true)]
        [string]$Value,
        [Parameter(Mandatory=$false)]
        [string]$Password
    )
	
$PSWD = (Get-WmiObject -Class Lenovo_BiosPasswordSettings -Namespace root\wmi).PasswordState
# Write-Output $PasswordState
	
    $SETBIOS = (Get-WmiObject -class Lenovo_SetBiosSetting -Namespace "root\wmi")
    $SAVEBIOS = (Get-WmiObject -class Lenovo_SaveBiosSettings -namespace "root\wmi")
    # with a password
    if ($PSWD -eq 2) {
        $BIOS_PW = "$password"
        $BIOS_TYPE = "acsii"
		$KEY_BIND = "us"
        $SETBIOS.SetBiosSetting("$Setting,$Value,$BIOS_PW,$BIOS_TYPE,$KEY_BIND")
        $SAVEBIOS.SaveBiosSettings("$BIOS_PW,$BIOS_TYPE,$KEY_BIND")

    }
    # without a password
    else {
        $SETBIOS.SetBiosSetting("$Setting,$Value")
        $SAVEBIOS.SaveBiosSettings()
    }
}
 
#Set-BIOSSetting -Setting "Wake On Lan" -Value "Automatic" -Password "AFNI"
Set-BIOSSetting -Setting "Wireless LAN" -Value "Disabled" -Password "strangel0ve"