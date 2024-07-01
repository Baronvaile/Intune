#Try-Catch for error handling
Try {
    # After you export the RegKey, be sure you copy/paste it HERE: https://reg2ps.azurewebsites.net/
    # This will create the detection script and the remediation script. 
    
    #if (-NOT (Test-Path -Path "HKLM:\SYSTEM\" -Value "AFNI_Machine")) { Exit 1 };
    #if (Get-Item -Path "HKLM:\SYSTEM\" -Value "AFNI_Machine") { Exit 0 }
    $keyExists = (Get-ItemProperty -Path "HKLM:\SYSTEM" -Name "AFNI_Machine" -ErrorAction SilentlyContinue)
	$2ndkeyExists = ((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM' -Name '001' -ea SilentlyContinue) -eq "F5lDAKHfivs^Q`$faptis8oI767^CPdcbFgQhXKNxwUBsRU8u3r")
    $3rdkeyexists = ((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Windows' -Name 'k9q2u6MHEmg6UTE' -ea SilentlyContinue) -eq "SyKc7V533*9CrECQszM5Ah3g8j9!&8uzjPZyet%yXEjUC8qx#&")
    $4thkeyexists = ((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Microsoft' -Name 'v68URzJWXm3inMH' -ea SilentlyContinue) -eq "HKBHV&y6U4@Fxano6@mUoRfRRGPnkGv8Svv9Q4ybL@H@fVZVKK")
        if($keyExists -and $2ndkeyExists -and $3rdkeyexists -and $4thkeyexists) {exit 0}
    else { exit 1 }
    
}Catch{
    #captures and reports the exception errors of the script
    Write-Host $_.Exception
    Exit 2000
}