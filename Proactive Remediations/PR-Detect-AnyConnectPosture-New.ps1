#Try-Catch for error handling
Try {
    # After you export the RegKey, be sure you copy/paste it HERE: https://reg2ps.azurewebsites.net/
    # This will create the detection script and the remediation script. 
    
    #if (-NOT (Test-Path -Path "HKLM:\SYSTEM\" -Value "AFNI_Machine")) { Exit 1 };
    #if (Get-Item -Path "HKLM:\SYSTEM\" -Value "AFNI_Machine") { Exit 0 }
    $1stkeyExists = ((Get-ItemProperty -LiteralPath 'HKLM:\Software\AFNI' -Name 'AFNI_Machine' -ea SilentlyContinue))
	$2ndkeyExists = ((Get-ItemPropertyValue -LiteralPath 'HKLM:\Software\AFNI' -Name '001' -ea SilentlyContinue) -eq 'F5lDAKHfivs^Q$faptis8oI767^CPdcbFgQhXKNxwUBsRU8u3r')
    $3rdkeyExists = ((Get-ItemPropertyValue -LiteralPath 'HKLM:\Software\AFNI' -Name '002' -ea SilentlyContinue) -eq 'Jck6ELGhps3J@9*VhVLC9f2odTyC36SUNve5&CvdH7^8B$omr')
    If ($1stkeyExists -And $2ndkeyExists -And $3rdkeyExists) { exit 0 }
    else { exit 1 }



    
}Catch{
    #captures and reports the exception errors of the script
    Write-Host $_.Exception
    Exit 2000
}