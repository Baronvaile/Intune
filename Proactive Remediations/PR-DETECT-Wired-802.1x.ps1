# Detection script to check that the Windows Service "Wired Autoconfig (dot3svc)" is set to automatic and running.
# AaronSharp V1.0 
$ServiceName = "dot3Svc"
$wiredServiceStartup = Get-Service -Name 'dot3svc'

Try {
      If ($wiredServiceStartup.StartType -eq 'Automatic' -And $wiredServiceStartup.Status -eq 'Running'){
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