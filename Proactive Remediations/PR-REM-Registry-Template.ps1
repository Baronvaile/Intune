# Template for Proactive Remediations


#Try-Catch for error handling
Try {
    # After you export the RegKey, be sure you copy/paste it HERE: https://reg2ps.azurewebsites.net/
    # This will create the detection script and the remediation script. 
    
    $keyExists = (Get-ItemProperty -Path 'HKLM:\SYSTEM').AFNI_Machine
    if( $null -eq $keyExists )  {  
    
    #(Test-Path "HKLM:\SYSTEM\" -Value "AFNI_Machine") -ne $true) {
        <# Action to perform if the condition is true #>
        New-ItemProperty -Path "HKLM:\SYSTEM\" -Name "AFNI_Machine" -PropertyType "string"
    }
    
}Catch{
    #captures and reports the exception errors of the script
    Write-Host $_.Exception
    Exit 2000
}