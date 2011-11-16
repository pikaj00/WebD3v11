#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
#use lib './';
#************************************************************************************
#Build 1011A0001
#************************************************************************************
use Account;
my $RunOnceTag="RunOnce.ini";
my $account = new Account(config=>'Configuration.pl');
$account->connectDb;
print "Content-type: text/html\n\n";
print qq|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>iDC File Manager :: MySQL Table Creation Tool</title>
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
<td colspan="2" class="of"><b>iDC File Manager :: MySQL Table Creation Tool</td>
</tr>
<tr>
</tr>|;
$account->dbh->do("drop table $account->{tblAccounts}");
$account->dbh->do("drop table $account->{tblGroups}");
$account->dbh->do("drop table $account->{tblFolders}");
$account->dbh->do("drop table $account->{tblUserGroup}");
$account->dbh->do("drop table $account->{tblGroupFolder}");
$account->dbh->do("drop table $account->{tblNotes}");
$account->dbh->do("create table $account->{tblAccounts} (
        id int(11) not null auto_increment,
        login varchar(200) not null,
        password varchar(64),
        email varchar(128),
        home  varchar(200),
        diskquota varchar(11),
        protect varchar(255),
        rights varchar(255),
        disabled int(1) default 0,
        expired datetime,
        limitdays varchar(11),
        first varchar(64),
        last varchar(64),
        country varchar(64),
        zip varchar(64),
        city varchar(64),
        state varchar(64),
        address varchar(64),
        phone varchar(64),
        fax varchar(64),
        company varchar(64),
        comments text,
        additional1  varchar(128),
        additional2  varchar(128),
        additional3  varchar(128),
        additional4  varchar(128),
        additional5  varchar(128),
        primary key(id),
        unique key(login),
        key (disabled),
        key (home)
);") or die $account->dbh->errstr;

$account->dbh->do("insert into $account->{tblAccounts} (id,login,password,email,home,diskquota,protect,rights,disabled,expired,limitdays,first,last,country,zip,city,state,address,phone,fax,company,comments,additional1,additional2,additional3,additional4,additional5) values(1, 'admin', 'oL5T.XiJ35MVQ', '', 'admin', '', '', 'u,r,z,m,o,a,v,t,c,p,k,n,w,l,d', NULL, NULL, '', '', '', '', '', '', '', '', '', '', '', '', NULL, NULL, NULL, NULL, NULL);") or die $account->dbh->errstr;
mkdir "$account->{'clientroot'}/admin";
print qq|
    <td>2) Admin Account: <b>admin</b> created and added to database.</td>
</tr>|;



$account->dbh->do("create table $account->{tblGroups}(
        id int(11) not null auto_increment,
        name varchar(64) not null,
        groupemail varchar(64) not null,
        disabled int(11),
        description text,

        primary key(id),
        key (disabled));")  or die $account->dbh->errstr;

print qq|
    <td>3) Table: <b>$account->{tblGroups}</b> created.</td>
</tr>|;


$account->dbh->do("insert into $account->{tblGroups} (id,name,groupemail,disabled,description) values(1, 'admin', '', NULL, '');") or die $account->dbh->errstr;

print qq|
    <td>4) Admin Group: <b>admin</b> created.</td>
</tr>|;

$account->dbh->do("create table $account->{tblFolders}(
        id int(11) not null auto_increment,
        name varchar(64) not null,
        path  varchar(255) not null,
        slimit varchar(11),
        disabled int(11),
        description text,

        primary key(id),
        key (disabled)
);") or die $account->dbh->errstr;

print qq|
    <td>5) Table: <b>$account->{tblFolders}</b> created.</td>
</tr>|;

$account->dbh->do("create table $account->{tblUserGroup}(
        id int(11) not null auto_increment,
        userId int(11) not null,
        groupId  int(11) not null,

        primary key(id),
        key(userId),
        key(groupId)
);") or die $account->dbh->errstr;

print qq|
    <td>6) Table: <b>$account->{tblUserGroup}</b> created.</td>
</tr>|;

$account->dbh->do("insert into $account->{tblUserGroup} (id,userId,groupId) values(1, 1, 1);") or die $account->dbh->errstr;

print qq|
    <td>7) Admin Account: <b>admin</b> added to Group: <b>admin</b>.</td>
</tr>|;

$account->dbh->do("create table $account->{tblGroupFolder}(
        id int(11) not null auto_increment,
        groupId  int(11) not null,
        folderId int(11) not null,
        rights varchar(255),
        useCustomProtect int(11),
        protect varchar(255),

        description text,
        primary key(id),
        key(groupId),
        key(folderId)
);") or die $account->dbh->errstr;

print qq|
    <td>8) Table: <b>$account->{tblGroupFolder}</b> created.</td>
</tr>|;

$account->dbh->do("create table $account->{tblNotes}(
        id int(11) not null auto_increment,
        file varchar(255),
        userId int(11),
        user varchar(64),
        date datetime,
        note text,
        primary key(id),
        key(userId)
);") or die $account->dbh->errstr;

print qq|
    <td>9) Table: <b>$account->{tblNotes}</b> created.</td>
</tr>|;
print qq|
    <td>10) MySQL Database and Tables setup.</td>
</tr>|;

print qq|
    <td>Status: <b>[COMPLETE]</b></td>
</tr>|;
exit;
