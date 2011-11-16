#!/usr/bin/perl
use strict;
#use lib './';
#************************************************************************************
#Build 1011A0001
#************************************************************************************
use CGI::Carp qw(fatalsToBrowser);

##########################################################################
################## iDC File Manager Version 1.5.00 #######################
############################DATABASE IMPORTER#############################
##########################################################################


####User Database#########################################################

my $notesTable ="notes.txt";
#Enter the name of the existing File Manager version 1.4 or earlier Database name.
#If the Database cannot be opened or found by the script try entering the full path:
#e.g my $notesTable ="/home/yoursite/public_html/cgi-bin/FileManager/notes.txt";

##########################################################################


##########################################################################

#DO NOT MODIFY BELOW THIS LINE!!!!!!
#DO NOT MODIFY BELOW THIS LINE!!!!!!
#DO NOT MODIFY BELOW THIS LINE!!!!!!
#DO NOT MODIFY BELOW THIS LINE!!!!!!


##########################################################################
##########################################################################
##########################################################################
##########################################################################
##########################################################################


print "Content-type: text/html\n\n";

print qq|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
        <title>iDC File Manager :: User Account Importer</title>
        <style>
            td, th {font-family: Verdana, Arial; font-size:8pt}
            input,select {font-family: Verdana, Arial; font-size:8pt}
                .titel  {font-family: Verdana, Arial; font-size:10pt; font-weight:bolder; color: #999999}
                .of {border-style:solid; border-width: 1; border-color : #7c96af; background-color:#dddddd; font-size:8pt}
                .off {border-style:none;background-color:#f3f3f3}
        </style>
</head>
<body>
<br>
<table cellspacing="2" cellpadding="2" border="0" class="off" align="center" width="600">
<tr><td colspan="2" align="right"><font color="red"</font></td></tr>
<tr>
    <td colspan="2" class="of"><b>iDC File Manager :: Notes Account Importer</td>
</tr>
<tr>
</tr>|;


(our $script=$0) =~s!^.*[/\\]!!;
use Account;
use Data::Dumper;
use Date::Parse;

my $account = new Account(config=>'Configuration.pl', SCRIPT=>$script);


open (F, "$notesTable") or die $!;
my @data=<F>;
close F;

my $sth = $account->dbh->prepare("SELECT id FROM $account->{tblAccounts} WHERE login=?");
my $count;
for (@data){
        $_=~s/\r|\n//g;
        my @row = split '##', $_;
        #/home/idcfilem/public_html/Clients/install.log##Admin##Wed Dec 20 10:05:34 2006##test

        $sth->execute($row[1]) or die $account->dbh->errstr;
        my ($id) = $sth->fetchrow_array;
        my @date = strptime($row[2]);
        #print "userId=>$id,file=>$row[0],login=>$row[1],\n<br>";
                next unless ($id && $row[1]);
        $account->saveNote(userId=>$id,file=>$row[0],login=>$row[1],date=>sprintf("%04D-%02D-%02D %02D:%02D:%02D", $date[5]+1900,$date[4]+1,$date[3],$date[2],$date[1],$date[0] ),note=>$row[3]);
        $count++;
}

 print "<tr><td colspan='2'>Status: <b>[COMPLETE]</b> $count records inserted.</td></tr></table>";

 #print Dumper($account->getNotes);

