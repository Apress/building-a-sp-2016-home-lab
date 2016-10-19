Connect-SPConfigurationDatabase -DatabaseName PRD_SharePoint_ConfigDB -DatabaseServer SPAlias -Passphrase (ConvertTo-SecureString "1Qaz2Wsx3Edc4Rfv" -AsPlainText -Force)  -localserverrole distributedCache
Install-SPHelpCollection -All
Initialize-SPResourceSecurity
Install-SPService
Install-SPFeature -AllExistingFeatures
Install-SPApplicationContent
Start-Service SPTimerV4