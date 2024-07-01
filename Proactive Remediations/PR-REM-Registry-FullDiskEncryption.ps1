# https://github.com/andrew-s-taylor/public/blob/main/Powershell%20Scripts/remediate-fastboot.ps1

#New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
Remove-Item -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\FVE' -Force -Verbose