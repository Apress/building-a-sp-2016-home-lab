Set-ExecutionPolicy Unrestricted

Add-PSSnapin microsoft.sharepoint.powershell -ErrorAction SilentlyContinue
Remove-PSSnapin microsoft.sharepoint.powershell -ErrorAction SilentlyContinue
Add-PSSnapin microsoft.sharepoint.powershell -ErrorAction SilentlyContinue

Write-Host "When prompted for credentials, give SharePoint the farm account, not the install account that you are signed in with, then provide the passphrase, note: you will not be prompted for passPhrase if it is baked into the script" -ForegroundColor green

New-SPConfigurationDatabase -DatabaseName PRD_SharePoint_ConfigDB -DatabaseServer SPAlias -Passphrase (ConvertTo-SecureString "1Qaz2Wsx3Edc4Rfv" -AsPlainText -Force) -FarmCredentials (Get-Credential) -AdministrationContentDatabaseName PRD_SharePoint_CentralAdmin_Content -SkipRegisterAsDistributedCacheHost -localserverrole Application

#Enter the port for Central Admin and the Authentication Provider if different than NTLM#

$CAPort = 11111
$CAAuth = “NTLM”


#Must use this order http://technet.microsoft.com/en-us/library/ff806336(v=office.14).aspx##


Install-SPHelpCollection -All
Initialize-SPResourceSecurity
Install-SPService
Install-SPFeature -AllExistingFeatures

New-SPCentralAdministration -Port $CAPort -WindowsAuthProvider $CAAuth

Install-SPApplicationContent

New-ItemProperty HKLM:\System\CurrentControlSet\Control\Lsa -Name “DisableLoopbackCheck” -value “1” -PropertyType dword

$ServiceConnectionPoint = get-SPTopologyServiceApplication | select URI

Set-SPFarmConfig -ServiceConnectionPointBindingInformation $ServiceConnectionPoint -Confirm: $False

Write-Host "Make sure to register the managed accounts for Service Apps and for Web Content before continuing with the 2013Install script" -ForegroundColor Blue -BackgroundColor white
Write-Host "#######################################################################################################################################" -ForegroundColor Blue -BackgroundColor White
Write-Host "Have a great SharePoint Day. . ." -ForegroundColor Green
Write-Host "#######################################################################################################################################" -ForegroundColor Green

