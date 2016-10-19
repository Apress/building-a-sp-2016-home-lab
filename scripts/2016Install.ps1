<# Check line 8, line 12, line 16, and line 55 and check all databasename, log path, and account variables correspond with your naming convention 
Based on scripts at http://www.harbar.net/articles/sp2013mt.aspx and http://www.toddklindt.com/blog/Lists/Posts/Post.aspx?ID=378
Thanks Todd and Spencer!
This should be run on the first server in your farm #>

#Creates the Default Service Application Pool#

New-SPServiceApplicationPool -Name “Default SharePoint Service App Pool” -Account “Tailspintoys\svc_svcacct”

## Replace values between < > with correct values and remove < >#

$DatabaseServerName = “SPAlias“

$AppPoolName = “Default SharePoint Service App Pool”

$AppPoolUserName = “Tailspintoys\svc_svcacct“

$SAAppPool = Get-SPServiceApplicationPool -Identity $AppPoolName -EA 0

if($SAAppPool -eq $null)

{

$AppPoolAccount = Get-SPManagedAccount -Identity $AppPoolUserName -EA 0

if($AppPoolAccount -eq $null)

{

$AppPoolCred = Get-Credential $AppPoolUserName

$AppPoolAccount = New-SPManagedAccount -Credential $AppPoolCred -EA 0

}

$AppPoolAccount = Get-SPManagedAccount -Identity $AppPoolUserName -EA 0

if($AppPoolAccount -eq $null)

{

Write-Host “Cannot create or find the managed account $appPoolUserName, please ensure the account exists.”

Exit -1

}

New-SPServiceApplicationPool -Name $SAAppPoolName -Account $AppPoolAccount -EA 0 > $null

}

##Configure Farm Service Applications

## Create Usage and Health Data Collection Service and State Service Applications, replace variables with desired values for database names, etc. ##

## Begin Variables for usage and health data collection and state service, make sure the E: location exists first ##
$usageSAName = “Usage and Health Data Collection Service”
$usageServiceDBName = “PRD_Usage_HealthDataDB”
$usageLogLocationOnDisk = “E:\logs\ULS\”
$stateSAName = “State Service”
$stateServiceDatabaseName = “PRD_StateServiceDataDB”
## End Variables ##

Set-SPUsageService -LoggingEnabled 1 -UsageLogLocation $usageLogLocationOnDisk -UsageLogMaxSpaceGB 2

$serviceInstance = Get-SPUsageService

New-SPUsageApplication -Name $usageSAName -DatabaseServer $DatabaseServerName -DatabaseName $usageServiceDBName -UsageService $serviceInstance > $null

$stateServiceDatabase = New-SPStateServiceDatabase -Name $stateServiceDatabaseName

$stateSA = New-SPStateServiceApplication -Name $stateSAName -Database $stateServiceDatabase

New-SPStateServiceApplicationProxy -ServiceApplication $stateSA -Name “$stateSAName Proxy” -DefaultProxyGroup

## Create Managed Metadata Service (If Upgrading Use Existing Database Name of database that was attached) ##

$metadataSAName = “Managed Metadata Service”
$metadataDBName = “PRD_ManagedMetadataDB”

$mmsApp = New-SPMetadataServiceApplication -Name $metadataSAName –ApplicationPool $AppPoolName -DatabaseServer $DatabaseServerName -DatabaseName $metadataDBName > $null

New-SPMetadataServiceApplicationProxy -Name “$metadataSAName Proxy” -DefaultProxyGroup -ServiceApplication $metadataSAName > $null

Get-SPServiceInstance | where-object {$_.TypeName -eq “Managed Metadata Web Service”} | Start-SPServiceInstance > $null






## Word ##

$wordAutomationServiceName = “Word Automation Service Application”
$wordAutomationDatabaseName = “PRD_WordAutomationDataDB“

Get-SPServiceApplicationPool –Identity $AppPoolName | New-SPWordConversionServiceApplication -Name $wordAutomationServiceName -DatabaseName $wordAutomationDatabaseName

## BDC (If Upgrading Use Existing Database Name) ##

$BDCServiceName = “Business Data Connection Service Application”
$BDCDatabaseName = “PRD_BusinessDataConnectionDataDB“

New-SPBusinessDataCatalogServiceApplication –ApplicationPool “Default SharePoint Service App Pool” –DatabaseName $BDCDatabaseName –DatabaseServer $DatabaseServerName –Name $BDCServiceName

###  New-SPBusinessDataCatalogServiceApplicationProxy -Name “Business Data Connection Service Application Proxy” -ServiceApplication “Business Data Connection Service Application”##

## Secure Store (If Upgrading Use Existing Database Name) ##

#See page 162 - - previously did not have variable instantiation of the service app, and was trying to call the app by name on the proxy line versus the variable###

$SecureStoreServiceAppName = “Secure Store Service Application”
$SecureStoreDBName = “PRD_SecureStoreServiceDB”

$SecureStoreServiceApp = New-SPSecureStoreServiceApplication –ApplicationPool $AppPoolName –AuditingEnabled:$false –DatabaseServer $DatabaseServerName –DatabaseName $SecureStoreDBName –Name $SecureStoreServiceAppName

New-SPSecureStoreServiceApplicationProxy –Name “Secure Store Service Application Proxy” –ServiceApplication $SecureStoreServiceApp -DefaultProxyGroup

## Performance Point (If Upgrading Use Existing Database Name) ##

$PerformancePointAppProxyName = “Performance Point Service Application Proxy”
$PerformancePointAppName = “Performance Point Service Application”
$PerformancePointDatabase = “PRD_PerformancePointDataDB”


New-SPPerformancePointServiceApplication -Name $PerformancePointAppName -ApplicationPool $AppPoolName -DatabaseName $PerformancePointDatabase

New-SPPerformancePointServiceApplicationProxy -Name $PerformancePointAppProxyName -ServiceApplication $PerformancePointAppName -Default


## Create Subscription Settings and App Management Services ##  See minute 40 point int video dated 8/4/2014####

$SubSettingssName = “Subscription Settings Service”

$SubSettingsDatabaseName = “PRD_SubscriptionSettingsDB”

$AppManagementName = “App Management Service”

$AppManagementDatabaseName = “PRD_AppManagementDB”

$AppPoolName = “Default SharePoint Service App Pool”

$DatabaseServerName = “SPAlias“

Write-Host “Creating Subscription Settings Service and Proxy…”

$SubSvc = New-SPSubscriptionSettingsServiceApplication –ApplicationPool $AppPoolName –Name $SubSettingssName –DatabaseName $SubSettingsDatabaseName

$SubSvcProxy = New-SPSubscriptionSettingsServiceApplicationProxy –ServiceApplication $SubSvc

Get-SPServiceInstance | where-object {$_.TypeName -eq $SubSettingssName} | Start-SPServiceInstance > $null

Write-Host “Creating App Management Service and Proxy…”

$AppManagement = New-SPAppManagementServiceApplication -Name $AppManagementName -DatabaseServer $DatabaseServerName -DatabaseName $AppManagementDatabaseName –ApplicationPool $AppPoolName

$AppManagementProxy = New-SPAppManagementServiceApplicationProxy -ServiceApplication $AppManagement -Name “$AppManagementName Proxy”

Get-SPServiceInstance | where-object {$_.TypeName -eq $AppManagementName} | Start-SPServiceInstance > $null

Set-SPAppDomain apps.Tailspintoys.com

Set-SPAppSiteSubscriptionName -Name “apps” -Confirm:$false

## Create Machine Translation Service ##

$AppPool = “Default SharePoint Service App Pool”

$MTSInst = “Machine Translation Service”

$MTSName = “Translation Service”

$MTSDB = “PRD_MachineTranslationDB”

$AppPoolName = Get-SPServiceApplicationPool $AppPool

Get-SPServiceInstance | ? {$_.GetType().Name -eq $MTSInst} | Start-SPServiceInstance

$MTS = New-SPTranslationServiceApplication -Name $MTSName -ApplicationPool $AppPoolName -DatabaseName $MTSDB

$MTSProxy = New-SPTranslationServiceApplicationProxy –Name “$MTSName Proxy” –ServiceApplication $MTS –DefaultProxyGroup


Write-Host "Time to configure User Profile Service, Visio, Excel,Performance Point. . ." -ForegroundColor White
Write-Host "##########################################################################################" -ForegroundColor White
Write-Host "Configure Publishing Infrastructure. . ." -ForegroundColor White
Write-Host "##########################################################################################" -ForegroundColor White
Write-Host "And, Time to run the enable .Net Session State and install Workflow Manager 1.0. . ." -ForegroundColor White
Write-Host "##########################################################################################" -ForegroundColor White
Write-Host "Have a great SharePoint Day. . ." -ForegroundColor White
Write-Host "##########################################################################################" -ForegroundColor White