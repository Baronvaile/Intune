# Template for Proactive Remediations
$value = 0
#Try-Catch for error handling
Try {
    # After you export the RegKey, be sure you copy/paste it HERE: https://reg2ps.azurewebsites.net/
    # This will create the detection script and the remediation script. 
    
    #if (-NOT (Test-Path -Path "HKLM:\SYSTEM\" -Value "AFNI_Machine")) { Exit 1 };
    #if (Get-Item -Path "HKLM:\SYSTEM\" -Value "AFNI_Machine") { Exit 0 }
    $keyExists = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\FVE').FDVRequireActiveDirectoryBackup
#    if( $null -eq $keyExists ) {exit 1}

#    else {exit 0 }
    
#}Catch{
    #captures and reports the exception errors of the script
#    Write-Host $_.Exception
#    Exit 2000
#}


If ($keyExists -eq $Value){
    Write-Output "Compliant"
    Exit 0
} 
Write-Warning "Not Compliant"
Exit 1
} 
Catch {
Write-Warning "Not Compliant"
Exit 1
}