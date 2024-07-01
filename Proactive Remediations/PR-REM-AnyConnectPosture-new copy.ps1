# Template for Proactive Remediations


#Try-Catch for error handling
Try {
    # After you export the RegKey, be sure you copy/paste it HERE: https://reg2ps.azurewebsites.net/
    # This will create the detection script and the remediation script. 
    
    New-Item -Path HKLM:\Software\AFNI
    New-ItemProperty -Path "HKLM:\Software\AFNI" -Name "AFNI_Machine" -PropertyType "string" -ErrorAction SilentlyContinue
    New-ItemProperty -Path "HKLM:\Software\AFNI" -Force -Name "001" -PropertyType "string" -Value 'F5lDAKHfivs^Q$faptis8oI767^CPdcbFgQhXKNxwUBsRU8u3r' -ErrorAction SilentlyContinue
    New-ItemProperty -Path "HKLM:\Software\AFNI" -Force -Name "002" -PropertyType "string" -Value 'Jck6ELGhps3J@9*VhVLC9f2odTyC36SUNve5&CvdH7^8B$omr' -ErrorAction SilentlyContinue
    
}Catch{
#captures and reports the exception errors of the script
Write-Host $_.Exception
Exit 2000
}