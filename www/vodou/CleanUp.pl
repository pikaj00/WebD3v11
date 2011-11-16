#!/usr/bin/perl
use strict;
#************************************************************************************
#Build 1011A0001
#************************************************************************************
use CGI::Carp qw(fatalsToBrowser);
use Account;

my $RunOnceTag="RunOnce.ini";

my $account = new Account(config=>'Configuration.pl');
$account->connectDb;

print "Content-type: text/html\n\n";

print qq|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>iDC File Manager :: MySQL Table Clean Up Tool</title>
<style>
td, th {font-family: Verdana, Arial; font-size:8pt}
.of {border-style:solid; border-width: 1; border-color : #7c96af; background-color:#dddddd; font-size:8pt}
.off {border-style:none;background-color:#f3f3f3}
</style>
</head>
<body>
<br>
<table cellspacing="2" cellpadding="2" border="0" class="off" align="center" width="600">
<tr><td colspan="2" align="right"><font color="red"</font></td></tr>
<tr>
<td colspan="2" class="of"><b>iDC File Manager :: MySQL Table Clean Up Tool</td>
</tr>
<tr>
</tr>|;

if (-e "RunOnce.ini") {
print qq|<td><b>Error:</b> The MySQL Table Clean Up Tool has already been run on this server and cannot be <br>run again until the RunOnce.ini file is deleted.</td></tr>|;
}
else {
open(DAT,">>$RunOnceTag") || die("Cannot Open File");
print DAT "MySQL Table Clean Up Tool :: Run Once \n\nTo run the MySQL Table Clean Up Tool please delete this file.";
close(DAT);
$account->dbh->do("drop table $account->{tblAccounts}");

print qq|
    <td>1) Table: <b>$account->{tblAccounts}</b> Deleted.</td>
</tr>|;

$account->dbh->do("drop table $account->{tblGroups}");

print qq|
    <td>3) Table: <b>$account->{tblGroups}</b> Deleted.</td>
</tr>|;

$account->dbh->do("drop table $account->{tblFolders}");

print qq|
    <td>5) Table: <b>$account->{tblFolders}</b> Deleted.</td>
</tr>|;

$account->dbh->do("drop table $account->{tblUserGroup}");

print qq|
    <td>6) Table: <b>$account->{tblUserGroup}</b> Deleted.</td>
</tr>|;

$account->dbh->do("drop table $account->{tblGroupFolder}");

print qq|
    <td>8) Table: <b>$account->{tblGroupFolder}</b> Deleted.</td>
</tr>|;

$account->dbh->do("drop table $account->{tblNotes}");

print qq|
    <td>9) Table: <b>$account->{tblNotes}</b> Deleted.</td>
</tr>|;
print qq|
    <td>10) MySQL Database and Tables Deleted.</td>
</tr>|;

print qq|
    <td>Status: <b>[COMPLETE]</b></td>
</tr>|;
}
exit;
