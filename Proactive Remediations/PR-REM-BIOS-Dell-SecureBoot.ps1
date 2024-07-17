# Remediate Dell BIOS/UEFI setting

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

    # Detect the password state 
    $PSWD = Get-WmiObject -Class PasswordObject -Namespace "root\dcim\sysman\wmisecurity" |Where-Object {$_.NameId -eq "Admin"}

	
    $SETBIOS = Get-WmiObject -class BiosAttributeInterface -Namespace "root\dcim\sysman\biosattributes"
    
    # with a password
    if ($PSWD.IsPasswordSet -eq 1) {
        $Encoder = New-Object System.Text.UTF8Encoding
        $Bytes = $Encoder.GetBytes($Password)
        $SETBIOS.SetAttribute(1,$Bytes.Length,$Bytes,$Setting,$Value)
    }
    
    # without a password
    else {
        $SETBIOS.SetAttribute(0,0,0,$Setting,$Value)
    }
}


#Set-BIOSSetting -Setting "Wake On Lan" -Value "Automatic" -Password "AFNI"
Set-BIOSSetting -Setting "SecureBoot" -Value "Enabled" -Password "strangel0ve"