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
my $userTable ="users.txt";
#Enter the name of the existing File Manager version 1.4 or earlier Database name.
#If the Database cannot be opened or found by the script try entering the full path:
#e.g my $userTable ="/home/yoursite/public_html/cgi-bin/FileManager/users.txt";
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
    <td colspan="2" class="of"><b>iDC File Manager :: User Account Importer</td>
</tr>
<tr>
</tr>|;


(our $script=$0) =~s!^.*[/\\]!!;
use Account;
use Data::Dumper;

my $account = new Account(config=>'Configuration.pl', SCRIPT=>$script);


open (F, "$userTable") or die $!;
my @data=<F>;
close F;


my @fields = split '\|', shift @data;
@fields[@fields-1]=~s/\r|\n//g;
my $users=[];
for (@data){
        $_=~s/\r|\n//g;
        my @record = split '\|', $_;
        my $line={};
        for (my $i=0;$i<@fields;$i++){
                $line->{$fields[$i]}=$record[$i];
        }
        push @$users, $line;
}

#die Dumper($users);


for my $user (@$users){
        #check exists account
        my $sth = $account->dbh->prepare("SELECT id FROM $account->{tblAccounts} WHERE login=?");
        my $rv = $sth->execute($user->{login}) or die $account->dbh->errstr;
        $sth->finish;
         if ($rv ne '0E0'){
                 print "<td><B>Error: </B><font color='red'>Account: $user->{login} already exists in the MySql database!</font></td></tr>";
         }
         else{
                #mkdir "$account->{'clientroot'}/$user->{login}" or die "Can't create account home directory! $!";
                my $id = $account->createRecord(
                        table=>$account->{tblAccounts},
                        data=>{
                                login => $user->{login},
                                password => $user->{password},
                                email => $user->{email},
                                home => $user->{home},
                                diskquota => $user->{limit} || 0,
                                protect => $user->{protect},
                                rights => "r,u,z,c,v,p,k,t,l,o,a,m,w,n,d",
                                disabled => $user->{disabled},
                                expired => $user->{expired},
                                first => $user->{first},
                                last => $user->{last},
                                country => $user->{country},
                                zip => $user->{zip},
                                city => $user->{city},
                                state => $user->{state},
                                address => $user->{address},
                                phone => $user->{phone},
                                fax => $user->{fax},
                                company => $user->{company},
                                comments => $user->{comments},
                                additional1 => $user->{additional1},
                                additional2 => $user->{additional2},
                                additional3 => $user->{additional3},
                                additional4 => $user->{additional4},
                                additional5 => $user->{additional5},
                                }
                        );


                print "<td>$id) Account: <b>$user->{login}</b> imported from the $userTable file and added to MySql database.</td></tr>";

                }
}

                print "<td>Status: <b>[COMPLETE]</b></td></tr></table>";


