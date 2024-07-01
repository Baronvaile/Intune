# Template for Proactive Remediations


#Try-Catch for error handling
Try {
    # After you export the RegKey, be sure you copy/paste it HERE: https://reg2ps.azurewebsites.net/
    # This will create the detection script and the remediation script. 
    
    New-ItemProperty -Path "HKLM:\SYSTEM\" -Name "AFNI_Machine" -PropertyType "string" -ErrorAction SilentlyContinue
    New-ItemProperty -Path "HKLM:\SYSTEM\" -Name "001" -PropertyType "string" -Value "F5lDAKHfivs^Q`$faptis8oI767^CPdcbFgQhXKNxwUBsRU8u3r" -ErrorAction SilentlyContinue
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Windows" -Name "k9q2u6MHEmg6UTE" -PropertyType "string" -Value "SyKc7V533*9CrECQszM5Ah3g8j9!&8uzjPZyet%yXEjUC8qx#&"  -ErrorAction SilentlyContinue
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\" -Name "v68URzJWXm3inMH" -PropertyType "string" -Value "HKBHV&y6U4@Fxano6@mUoRfRRGPnkGv8Svv9Q4ybL@H@fVZVKK"  -ErrorAction SilentlyContinue

}Catch{
#captures and reports the exception errors of the script
Write-Host $_.Exception
Exit 2000
}