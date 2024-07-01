# Template for Proactive Remediations

#Try-Catch for error handling
Try {
    # After you export the RegKey, be sure you copy/paste it HERE: https://reg2ps.azurewebsites.net/
    # This will create the detection script and the remediation script. 
    
    #if (-NOT (Test-Path -Path "HKLM:\SYSTEM\" -Value "AFNI_Machine")) { Exit 1 };
    #if (Get-Item -Path "HKLM:\SYSTEM\" -Value "AFNI_Machine") { Exit 0 }
    $keyExists = (Get-ItemProperty -Path 'HKLM:\SYSTEM').AFNI_Machine
    if( $null -eq $keyExists ) {exit 1}

    else {exit 0 }
    
}Catch{
    #captures and reports the exception errors of the script
    Write-Host $_.Exception
    Exit 2000
}