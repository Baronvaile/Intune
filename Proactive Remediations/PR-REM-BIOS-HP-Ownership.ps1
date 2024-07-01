Function Set-HPBIOSSetting {
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
    $SETBIOS = Get-WmiObject -class hp_biossettinginterface -Namespace "root\hp\instrumentedbios"
    # with a password
    if ($Password.Length -ge 1) {
        $BIOS_PW = "<utf-16/>$password"
        $SETBIOS.SetBIOSSetting($Setting,$Value,$BIOS_PW)
    }
    # without a password
    else {
        $SETBIOS.SetBIOSSetting($Setting,$Value,"")
    }
}
 
Set-HPBIOSSetting -Setting "Ownership Tag" -Value "AFNI, Inc." -Password '$trangel0ve'