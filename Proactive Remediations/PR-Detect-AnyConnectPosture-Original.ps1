# Template for Proactive Remediations

#Try-Catch for error handling
Try {
    # After you export the RegKey, be sure you copy/paste it HERE: https://reg2ps.azurewebsites.net/
    # This will create the detection script and the remediation script. 
    
    if (-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\AFNI_Machine")) { Exit 1};
    if (Get-Item -LiteralPath "HKLM:\SYSTEM\AFNI_Machine") { Exit 0 }
    
}Catch{
    #captures and reports the exception errors of the script
    Write-Host $_.Exception
    Exit 2000
}