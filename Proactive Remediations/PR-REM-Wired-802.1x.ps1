#Remediation script to check that the Windows Service "Wired Autoconfig (dot3svc)" is set to automatic and running.
#AaronSharp V1.0 
$ServiceName = "dot3Svc"
$wiredServiceStartup = Get-Service -Name 'dot3svc'

If ($wiredServiceStartup.StartType -ne 'Automatic') {
    Set-service -Name dot3Svc -StartupType automatic
}

If ($wiredServiceStartup.Status -ne 'Running') {
    Start-Service -Name dot3Svc
    }