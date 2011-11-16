#####################################################################################
################## iDC File Manager Version 1.5.03 ##################################
###############################PRO VERSION###########################################
#####################################################################################

#####################################################################################
# i Dot Communications © 2009 - 2010 Copyright Mark Roberts / Alexandre Golovkine

#~~~~~~~ iDC File Manager - Usage ~~~~~~

# The iDC File Manager lite version cannot be used for Commercial usage.
# The same iDC File Manager - Pro / Pro Plus or OEM Version script cannot be used on multiple websites.
# For every 1 copy of iDC File Manager you purchase you will be provided with 1 "URL" licence.
# e.g.
# The file manager licensing only permits the File Manager to be run under 1 registered URL.
# Therefore if you purchase one license you can only run it under:
# http://www.mysite.com
# but not:http://www.mysite.com and http://www.mysite1.com or http://subdomain.mysite.com
# This means that for every subsequent website you intend to use the file manager with, you must purchase a new license.

# iDC File Manager - Pro version:
# Allows you to setup a maximum of 25 individual user accounts (user logins) to access the File Manager.
# The Pro version license does not permit you to use your own logos or modify the interface in any way.

# iDC File Manager - Pro Plus version:
# Allows you to setup an Unlimited number of individual user accounts (user logins) to access the File Manager.
# The Pro Plus version license does not permit you to use your own logos or modify the interface in any way.

# iDC File Manager - OEM version:
# Allows you to setup an Unlimited number of individual user accounts (user logins) to access the File Manager.
# The OEM version license permits you to own brand the File Manager and use your own logos and modify the
# toolbar artwork / icons / background etc... and customize the File Manager to your own requirements.

# iDC File Manager - Developer version allows you to setup the file manager on and unlimited number of servers
# and each installation can be accessed by an unlimited number of urls:
# e.g. www.yoursite.com/cgi-bin/FileManager/Manager.pl --> www.yoursite.com/cgi-bin/FileManager100000000000/Manager.pl
# Or www.customer/cgi-bin/FileManager/Manager.pl --> www.customer100000000000/cgi-bin/FileManager/Manager.pl
# Each copy of iDC File Manager installed allows an Unlimited number of individual user accounts (user logins)
# to access the File Manager.
# The Developer version license permits you to own brand the File Manager and use your own logos and modify the
# toolbar artwork / icons / background etc... and customize the File Manager to your own requirements.

# The scripts cannot be used to distribute:
# Pirated software
# Hacker programs
# Warez
# Pornography or nudity of any kind
# Copyrighted materials
# Any software that is copyrighted and not freely available for distribution without cost,
# including: ROMs, ROM Emulators and Mpeg Layer 3 files (MP3).
# The redistribution of modified versions of the scripts is prohibited.
# i Dot Communications accepts no responsibility or liability
# whatsoever for any damages however caused when using our services or scripts.
# By downloading and using this script you agree to the terms and conditions.

#####################################################################################

#####################################################################################
# For Instructions / Questions / Comments etc... Please visit:
# http://www.filemanager.net/site.php?page=TechnicalSupport
#####################################################################################

#************************************************************************************
#Build 1011A0001
#************************************************************************************

####File Manager - Version:##########################################################
Version ".03 PRO"
#####################################################################################

####Main File Manager Name###########################################################

FileManagerName "iDC File Manager"
#Do not modify the Main File Manager Name unless you hold an OEM License

#####################################################################################

#####################################################################################
#####################################################################################
#####################################################################################
############Modify The Following Sections Only!######################################

####File Manager - Registered Owner:#################################################

RegisteredOwner "Anonet Files"
#Change the "File Manager - Registered Owner:" to the name of your company or website etc...

#####################################################################################

####Main File Manager Title##########################################################

Filemanagertitle "Example - File Manager"
#Change the "File Manager Title" to the name of your company or website etc...

#####################################################################################

####MySQL Database Settings##########################################################

dns 'DBI:mysql:idc:localhost'
dbUser 'root'
dbPassword 'lulzsec'
#Change the "MySQL Database Settings" to correspond with
#the Mysql database you have setup.

#####################################################################################

####Main Clients Directory###########################################################

clientroot "/home/pikaj00/Filehost/Clients"
#Change the path to the "Main Clients Directory" to your servers path to the
#main public root directory + the sub-folder of the File Manager folder which will
#hold all your Clients folders.
#For example:
#e.g.clientroot "/var/www/fh/Clients"

#####################################################################################

####Main Shared Clients Directory####################################################

#Not available in iDC file Manager - Pro Version






#####################################################################################

####Main Template Directory##########################################################

templateDir "/home/pikaj00/Filehost/Templates"
#Change the path to the "Main Template Directory" to your servers path to the
#main public root directory + the sub-folder of the File Manager folder which will
#hold all your Template files.
#For example:
#e.g.templateDir "/var/www/fh/Templates"

#####################################################################################

####Main Language Messages Directory#################################################

languageMessagesFolder "/home/pikaj00/Filehost/Languages"
#Change the path to the "Main Language Messages Directory" to your servers path to
#the main public root directory + the sub-folder of the File Manager folder which will
#hold all your Language files.
#For example:
#e.g. languageMessagesFolder "/var/www/fh/Languages"

#####################################################################################

####Main Sessions Directories########################################################

sessionDir  "/var/www/cgi-bin/FileManager/sessions"

StoreRequestDir "/var/www/cgi-bin/FileManager/freeze"

#Change both paths to your servers path to the
#/cgi-bin/FileManager/ folder
#For example:
#e.g. sessionDir  "/home/yoursite/public_html/cgi-bin/FileManager/sessions"
#and
#e.g. StoreRequestDir "/home/yoursite/public_html/cgi-bin/FileManager/freeze"

#####################################################################################

####Skin Theme Config File###########################################################

alternativeConfigurationFile  "/var/www/fh/Skins.ini"
#Change the path to the "Skin Theme" to your servers path to
#the /cgi-bin/FileManager/ folder
#For example:
#e.g. alternativeConfigurationFile  "/home/yoursite/public_html/cgi-bin/FileManager/Skins.ini"



#####################################################################################

#####Analysis And Log Files - Activity Log###########################################

#Not available in iDC file Manager - Pro Version











#####################################################################################

####Main Image Directory#############################################################

htmlDataFolder "http://1.79.0.100/fh/FileManagerData"
#Change the url of the "Main Image Directory" to your servers url to
#the public root folder "FileManager" + the File Manager Image Directory
#called "FileManagerData"
#For example:
#e.g. htmlDataFolder "http://www.yoursite.com/FileManager/FileManagerData"

#####################################################################################

####Main Logo Directory##############################################################

htmlLogoFolder "http://www.yoursite.com/FileManager/FileManagerData/FileManagerLogos"
#Change the url of the "Main Logo Directory" to your servers url to the
#public root folder "FileManager" + the File Manager Image Directory
#called "FileManagerData"  +  "FileManagerLogos"
#For example:
#e.g. htmlLogoFolder "http://1.79.0.100/fh/FileManagerData/FileManagerLogos"



#####################################################################################

####Main Clients Directory##############################################################

htmlClientsFolder "http://1.79.0.100/fh/Clients"
#Change the url of the "Main Image Directory" to your servers url to the
#public root folder "FileManager" + the File Manager Main Clients Directory
#called "Clients"
#For example:
#e.g. htmlClientsFolder "http://www.yoursite.com/FileManager/Clients"

#####################################################################################

####Main Template Directory##########################################################

htmlTemplateFolder "http://1.79.0.11/fh/Templates"
#Change the url of the "Main Template Directory" to your servers url to the
#public root folder "FileManager" + the File Manager Main Template Directory
#called "Templates"
#For example:
#e.g. htmlTemplateFolder "http://www.yoursite.com/FileManager/Templates"

#####################################################################################

####Main Script URL##################################################################

scriptPath "http://1.79.0.11/cgi-bin/FileManager"
#Change the "Main Script URL" to your servers url to the cgi-bin
#+ the Main File Manager Directory called "FileManager"
#For example:
#e.g. scriptPath "http://www.yoursite.com/cgi-bin/FileManager"

#####################################################################################

####Upload Settings #################################################################

####HTTP And HTTPS Upload Settings####

#Linux servers only:
uploadPrBarOn "1"

#To enable the Upload Progress bar change:
#uploadPrBarOn "0" to: uploadPrBarOn "1" (Linux servers only)

#To disable the Upload Progress bar change:
#uploadPrBarOn "1" to: uploadPrBarOn "0"

####Flash Upload Settings####

secretWord  "fTf4m#G56sGH!"
#Do not modify the "secretWord" unless told to do so by iDC Support.

#####################################################################################

####Email Configuration Settings#####################################################

#Configure the email settings so that the iDC File Manager can
#send automated confirmation emails.

adminMail "pikaj000@gmail.com"

replyMail "pikaj000@gmail.com"

fromAdmin "pikaj000@gmail.com"
#From Email Address

toAdmin  "pikaj000@gmail.com"
#Email Address you want to receive email confirmations

sendMailPath "/usr/sbin/sendmail"
#SendMail Path

sendAsHtml "1"
#To enable HTML emails change sendAsHtml "0" to: sendAsHtml "1"
#To disable HTML emails change sendAsHtml "1" to: sendAsHtml "0"

sendConfirmAccount "0"
#To enable the option to send the Account details email to new
#users change sendConfirmAccount "0" to: sendConfirmAccount "1"
#To disable the option to send the Account details email to new
#users change sendConfirmAccount "1" to: sendConfirmAccount "0"

sendConfirmUpload "0"
#To enable the option to send Upload confirmation emails change
#sendConfirmUpload "0" to: sendConfirmUpload "1"
#To disable the option to send Upload confirmation emails change
#sendConfirmUpload "1" to: sendConfirmUpload "0"

sendConfirmFlashUpload "0"
#To enable the option to send Flash Upload confirmation emails change
#sendConfirmFlashUpload "0" to: sendConfirmFlashUpload "1"
#To disable the option to send Flash Upload confirmation emails change
#sendConfirmFlashUpload "1" to: sendConfirmFlashUpload "0"

sendToGroupUser "0"
#To enable the option to send Upload confirmation emails to
#Group users change sendToGroupUser "0" to: sendToGroupUser "1"
#To disable the option to send Upload confirmation emails to
#Group users change sendToGroupUser "1" to: sendToGroupUser "0"

sendConfirmDownload "0"
#To enable the option to send Download confirmation emails change
#sendConfirmDownload "0" to: sendConfirmDownload "1"
#To disable the option to send Download confirmation emails change
#sendConfirmDownload "1" to: sendConfirmDownload "0"

#####################################################################################

####Advanced Email Configuration#####################################################

#If you do not have SendMail installed on your server
#please configure the following option:

sendSMTP "1"
#To enable sendSMTP change sendSMTP  "0" to: sendSMTP  "1"
#To disable sendSMTP change sendSMTP  "1" to: sendSMTP  "0"

mailHostSMTP  "1.79.0.11"
#Enter your servers SMTP server address,
#e.g. mail.yoursite.com / smtp.yoursite.com / IP Address / Localhost

EmailAuthenticationON "0"

#To enable Email Authentication change
#EmailAuthenticationON "0" to: EmailAuthenticationON  "1"
#To disable Email Authentication change
#EmailAuthenticationON "1" to: EmailAuthenticationON  "0"

AuthenticationUsername ""
#Enter your servers Email Authentication username

AuthenticationPassword ""
#Enter your servers Email Authentication password

#####################################################################################

#####Client Manager - Control Panel Links Configuration##############################

customLink1 <a class="clientmanager" href="http://www.yoursite.com/link1.html" target="_blank">Custom Link 1</a>
customLink2 <a class="clientmanager" href="http://www.yoursite.com/link2.html" target="_blank">Custom Link 2</a>
customLink3 <a class="clientmanager" href="http://www.yoursite.com/link3.html" target="_blank">Custom Link 3</a>
customLink4 <a class="clientmanager" href="http://www.yoursite.com/link4.html" target="_blank">Custom Link 4</a>
customLink5 <a class="clientmanager" href="http://www.yoursite.com/link5.html" target="_blank">Custom Link 5</a>

#####################################################################################

#####File Manager - Menu Links##LEFT OFF HERE#####################################################

ContactUsLink "http://1.79.0.100/ContactUs.html"
#Change the Contact Us menu link that appears in the File Manager
#"Help" menu to your sites own Contact Page

#####################################################################################

#####Session Timeout#################################################################

timeOut "0"
#You may configure (if required) the session timeout period.
#If no mouse or keyboard activity is detected in the specified time frame
#the user will be logged out.
#The Session Timeout is entered in milliseconds. For example a 30 second
#session timeout would be entered as 30000.

#####################################################################################

####File Manager Description#########################################################

fileDescriptionOn "1"
#To enable File Descriptions change
#fileDescriptionOn "0" to: fileDescriptionOn "1"
#To disable File Descriptions change
#fileDescriptionOn "1" to: fileDescriptionOn "0"

#####################################################################################

####File Manager Date Stamp##########################################################

dateFormat "US"
#Change the dateFormat to:
#dateFormat "US"
#to date stamp all files using the American Date format (MM-DD-YYYY).
#dateFormat "EU"
#to date stamp all files using the European Date format (DD-MM-YYYY).
#dateFormat ""
#to date stamp all files using the ISO Date format (YYYY-MM-DD).

#####################################################################################

#####Auto Transfer Mode##############################################################

autoTxtType "txt, htm, html, cgi, pl, pm"
#Please enter the file extension you wish to be automatically uploaded in
#the ASCII format. Those not specified will be uploaded in Binary.

#####################################################################################

####Hidden Files#####################################################################

hideFiles "ion,htaccess,gacl"
#Specify file extensions you do not want to be shown and they will be
#automatically hidden from view when in "User Mode".

#####################################################################################

####Default Account Creation Properties##############################################

#Not available by default in iDC file Manager - Pro Version
#Available separately as a plug-in for: $47.00 (£31.00 / EUR37.00)
#For more information please visit:
#http://www.idotcommunications.co.uk/site.php?page=AccountCreation














































#####################################################################################

####Login Page - Signup Tab##########################################################

ShowSignupOption "hidden"
#Enable the iDC Account Creation sign-up tab to appear on the Login Page
#To enable the sign-up tab change
#ShowSignupOption "hidden" to: ShowSignupOption "visible"
#To disable the sign-up tab change
#ShowSignupOption "visible" to: ShowSignupOption "hidden"

#####################################################################################

####File Manager - Transfer Mode#####################################################

TransferModeDisplay "hidden"
#Show or Hide the Transfer Mode select menu in iDC File Manager
#To show the Transfer Mode select menu change
#TransferModeDisplay "hidden" to: TransferModeDisplay "visible"
#To hide the Transfer Mode select menu change
#TransferModeDisplay "visible" to: TransferModeDisplay "hidden"

#####################################################################################

####File Manager - Visual Quota Bar##################################################

quoteBarOn "1"
#Show or Hide the User Visual Quota Bar in iDC File Manager
#To show the Visual Quota Bar change quoteBarOn "0" to: quoteBarOn "1"
#To hide the Visual Quota Bar change quoteBarOn "1" to: quoteBarOn "0"

#####################################################################################

####File Manager - Account Expiry####################################################

autoExpireAfter "0"
#Specify the Number of days in which user accounts should expire after creation.
#As an example: autoExpireAfter '5' would force a user account to expire after 5 days.
#Please note: autoExpireAfter '0' is the default setting which will give user accounts
#an unlimited expiry period (i.e. they will not expire).

#####################################################################################

####Client Manager - Account Listings Per page#######################################

UsersPerPage "20"
#Specify the Number of User Account Listings per page in iDC Client Manager.

#####################################################################################

#####Master Setting For Banned File Upload Formats###################################

disabledFiles "exe,pl,php,cgi,php5,php4,js,java,dll"
#This setting stops the above file formats being uploaded in either admin
#or user mode and should not be modified unless told to do so by iDC Support.

#####################################################################################

#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################

####MySQL Table Settings#############################################################

tblAccounts 'accounts'
tblGroups 'groups'
tblFolders 'folders'
tblUserGroup 'user_group'
tblGroupFolder 'group_folder'
tblNotes 'notes'

#Do not modify the MySQL Table settings unless told to do so by iDC Support.

#####################################################################################

####Template Paths###################################################################

emlAdminConfirmation  'ApplicationNotification.html'
emlConfirmation  'ApplicationSignup.html'
emlApplFailed   'ApplicationFailed.html'
emlFileDownload 'DownloadEmail.html'
emlFileUpload 'UploadEmail.html'
msgAccountRestore 'ExpiredAccount.html'
tmpAccountsMain 'tmpAccountsMain.html'
tmpAccountForm 'tmpAccountForm.html'
tmpAccountFormEdit 'tmpAccountFormEdit.html'
tmpClients 'tmpClients.html'
tmpGroups  'tmpGroups.html'
tmpFolders 'tmpFolders.html'
tmpFolderForm 'tmpFolderForm.html'
tmpFolderDetails 'tmpFolderDetails.html'
tmpGroupForm 'tmpGroupForm.html'
tmpGroupDetails 'tmpGroupDetails.html'
tmpRights 'tmpRights.html'
tmpWndMain 'tmpWndMain.html'
msgAskCreateAccount 'ConfirmApplicationSignup.html'
msgCreateAccount 'ApplicationSignup.html'
msgForgottPassword 'ForgottenPassword.html'
tmpLogin 'tmpLogin.html'
tmpJoin 'Application.html'
tmpJoinConfirm 'ApplicationOk.html'
tmpJoinActivated 'ApplicationActivated.html'
tmpJoinNotify 'ApplicationNotification.html'
tmpAccountDetails 'tmpAccountDetails.html'
tmpLog  'ShowLog.html'
tmpErrorConfirm 'ApplicationConfirmError.html'

#####################################################################################

#####Session Cookie Name#############################################################

cookieName UserSID
#Do not modify the Session Cookie Name settings unless told to do so by iDC Support.

#####################################################################################

####Hotlink Pass Key#################################################################

hotLinkWord "KFMAESLPOSRRQ"
#Do not modify the Hotlink Pass Key name unless told to do so by iDC Support.

#####################################################################################

####Main File Manager Script:########################################################

FileManagerScriptName "Manager.pl"
#Do not modify the Main File Manager Script name unless told to do so by iDC Support.

#####################################################################################

####Main Client Manager Script:######################################################

ClientScriptName "ClientManager.pl"
#Do not modify the Main Client Manager Script name unless told to do so by iDC Support.

#####################################################################################

####Main Client Manager Script:######################################################

AccountCreationScriptName "AccountCreation.pl"
#Do not modify the Main Client Manager Script name unless told to do so by iDC Support.

#####################################################################################

#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################
