<#
INSTRUCTIONS for 2016:

- Check the values for the variables in lines 21-26 and adapt to your values in your domain
- - Run lines 21-26
- Make sure you like port number on line 21, 52, and 60.  Change it if you dont like it.  Use a high port
- - Run line 52 - Create the WEB Application
- Change the values for the variables in lines 56-60 and adapt to your values in your domain
- - Run line 62 - Create the Top Level Site
- Set the BackConnectionHostNames registry entries, Host file entries, and Binding on the applicable machines
- Set the values for the database names on lines 74 & 75 and make sure lines 85 & 86 and lines 90 & 91 "look ok" (e.g. have dns entries for the Cnames that are referenced in the URL & you like titles) - change to your domain if needed
- Set the site template at the end of lines 88 & 93, currently it is set for a blank site (STS#1) you might want a team site (STS#0) or maybe a publishing portal or search center - use get-spwebtemplate to find the templates for your desired site collection.
- - Run line 88 & line 93
- After the site is created open IIS on the servers that have the site and assign the SSL Certificate - -  If, and God forbid, you're not running SSL, then go through this and change all the https to http - - "I didnt say that"
#>



#Build a web application and place an empty site collection in it, a site collection with no site, e.g. pick site later or create with powershell as follows:

$applicationPool = "SharePoint - HNSC - 33333"
$ServiceAcct = "tailspintoys\svc_Content"
$svcacctmail = "svc_Content@tailspintoys.com"
$WebApp = "SharePoint HNSC Web Application"
$webAppURL = "https://hnsc.tailspintoys.com/"
$contentDB = "Prd_HNSC_ContentDB"

#######################################################################################################################################MAKE SURE TO UPDATE PORT#####

<#  
MOST OF THIS SCRIPT IS FOR SHAREPOINT 2016 or 2013  - - 2016 and 13 vs the earlier versions - Claims or no claims

The primary diffrence is whether your using claims or not.
If you're creating a HNSC for SharePoint 2013 you should use a claims based web application. For 2016 you must use a claims based web application.
Send the claims authentication provider by calling the new-spauthenticationprovider cmdlet into a variable as:  $Provider = New-spauthenticationprovider

THIS IS FOR A 2010 - NON claims based web application - or can use in 2013 if needed, normally you would use the $Provider = New-spauthenticationprovider along with the -AuthenticationProvider

New-SPWebApplication -ApplicationPool $applicationPool -ApplicationPoolAccount $serviceAcct -Name $WebApp -Port 33333 -databaseName $contentDB -securesocketslayer

#>

###########################################################################################################################################MAKE SURE TO UPDATE PORT#####
     ##
  ##   ##
##       ##     ##                      MAKE SURE TO UPDATE PORT IF YOU DONT LIKE IT
  ##   ##
##       ##

#If doing for 2013 or 2016

New-SPWebApplication -ApplicationPool $applicationPool -ApplicationPoolAccount $serviceAcct -Name $WebApp -Port 33333 -AuthenticationProvider (new-spauthenticationprovider) -databaseName $contentDB -secureSocketsLayer

#Now that the web app is there, add the bindings, build the empty site collection, assign the site collection admins

$primarySiteCollectionOwnerAcct = "tailspintoys\svc_content"
$PrimarySCOwnerEmail = "svc_content@tailspintoys.com"
$SecondarySiteCollectionOwnerAcct = "tailspintoys\spadmin"
$SecondarySCOwnerEmail = "spadmin@tailspintoys.com"
$webApp0URL = "https://hnsc.tailspintoys.com:33333"

New-SPSite -URL $webApp0URL -OwnerAlias $primarySiteCollectionOwnerAcct -OwnerEmail $PrimarySCOwnerEmail  -SecondaryOwnerAlias $SecondarySiteCollectionOwnerAcct -SecondaryEmail $SecondarySCOwnerEmail -Template STS#1

###################################
#####                         #####
##### ADD THE BINDINGS IN IIS ##### - - -  #### On All Servers, Add the BackconnectionHostNames ####
#####    on the servers       #####
#####   that have the sites   ##### - - -  #### Add host file entries on servers that have websites in IIS ####
#####                         #####
###################################

#Instantiate some DB names for the script

$HNSC1DB = "Prd_IT_ContentDB"
$HNSC2DB = "Prd_TBSPUG_ContentDB"


#Build some content databases for your new HNSC's

new-SPContentDatabase -Name $HNSC1DB -WebApplication $WebApp -WarningSiteCount 0 -MaxSiteCount 1
new-SPContentDatabase -Name $HNSC2DB -WebApplication $WebApp -WarningSiteCount 0 -MaxSiteCount 1

#Now build some HNSC's

$HNSC1Name = "Information Technology"
$HNSC1URL = "https://it.tailspintoys.com"

New-SPSite -url $HNSC1URL -HostHeaderWebApplication $webApp0URL -Name $HNSC1Name -ownerAlias $PrimarySiteCollectionOwnerAcct -owneremail $PrimarySCOwnerEmail -SecondaryOwnerAlias $SecondarySiteCollectionOwnerAcct -SecondaryEmail $SecondarySCOwnerEmail -contentDatabase $HNSC1DB -Template STS#1

$HNSC2Name = "Tailspintoys Best SharePoint Users Group"
$HNSC2URL = "https://TBSPUG.tailspintoys.com"

New-SPSite -url $HNSC2URL -HostHeaderWebApplication $webApp0URL  -Name $HNSC2Name -ownerAlias $PrimarySiteCollectionOwnerAcct -owneremail $PrimarySCOwnerEmail -SecondaryOwnerAlias $SecondarySiteCollectionOwnerAcct -SecondaryEmail $SecondarySCOwnerEmail -contentDatabase $HNSC2DB -Template STS#1
