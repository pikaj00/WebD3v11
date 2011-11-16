#!/usr/bin/perl
use strict;
#use lib './';
#************************************************************************************
#Build 1011A0001
#************************************************************************************
use CGI::Carp qw(fatalsToBrowser);
(our $script=$0) =~s!^.*[/\\]!!;
use Account;
use Data::Dumper;
use HTML::Entities;
my $account = new Account(config=>'Configuration.pl', SCRIPT=>$script);
$account->parseCGI;
my %SUB = (
users=>\&users,
user=>\&user,
new_user => \&newUser,
info  => \&infoUser,
groups => \&groups,
groupinfo => \&groupInfo,
new_group => \&newGroup,
folders => \&folders,
forgot => \&forgot,
new_folder => \&newFolder,
rights => \&rights,
groupFolder => \&groupFolder,
folderinfo => \&folderInfo,
logout => \&logout,
log=>\&log,
);
use CGI::Cookie;
my $sid = $account->getCookie($account->{cookieName});
if($account->{CGI}->{log_in}){
$account->getMessages( $account->{CGI}->{language} || $account->{currentUser}->{language}  || 'en');
$account->login(password=>$account->{CGI}->{password},login=>$account->{CGI}->{login});
#clear all old sessions
$account->clearSessions;
}
elsif($sid){
$account->currentUserBySid();
}
unless($account->currentUser){$account->login;}
my $user = $account->currentUser();
$account->login() unless $user->{isAdmin};
$account->getMessages( $account->{CGI}->{language} || $account->{currentUser}->{language}  || 'en');
$account->{CGI}{'action'} = 'users' unless defined $SUB{$account->{CGI}{'action'}};
$SUB{$account->{CGI}{'action'}}->();
exit;
sub users {
if ($account->{CGI}->{delete} && $account->{CGI}->{delete} ne $account->currentUser->{id}){
$account->deleteAccount($account->{CGI}->{delete});
print "Location: $script?action=users\n\n";
return;
}
$account->enableAccount($account->{CGI}->{enable}) if $account->{CGI}->{enable};
print "Content-type: text/html\n\n";
my $content = $account->showList(
table=>$account->{tblAccounts},
template=>$account->{'tmpClients'},
sort=>$account->{CGI}->{sort} || 'id',
desc=>$account->{CGI}->{desc},
);
my $groups = $account->getGroupList;;
my $opt = '<option value="">'.$account->{MESSAGES}->{all}.'</option>';
for(@$groups){
$opt .= "<option value=\"$_->{id}\"";
$opt .= " selected" if $_->{id} eq $account->{CGI}->{group};
$opt .= ">$_->{name}</option>";
}
$opt=qq~<a class="clientmanager">$account->{MESSAGES}->{group_users}</a>:
<select name="group" onchange="inst.group.value=this[this.selectedIndex].value; document.inst.submit();">
$opt
</select>~;
print $account->toHtml(
CONTENT=>$content,
TITLE=>$account->{MESSAGES}->{clientmanager_accounts},
NAVIGATION => '<b>Accounts</b>',
SELECTOR=>$opt,
PAGER=>$account->{_pager},
);
}
sub newUser {
my ($res, $data) = $account->createAccount() if $account->{CGI}->{submit};
if ($res){
print "Location: $script?action=info&account=$res\n\n";
return;
}
my $groups = $account->getList(
table=>$account->{tblGroups},
sort=>'name',
);
$data->{groups}="";
for(@$groups){
$data->{groups}.=qq~ <li><label><input type="checkbox" name="group" value="$_->{id}" >~.($data->{userGroups}->{$_->{id}}? 'checked':'').qq~ $_->{name}</label></li>~;
}
$data->{DATEFORMAT} = $account->{dateFormat} eq 'US'? 'MM-DD-YYYY' : $account->{dateFormat} eq 'EU'? 'DD-MM-YYYY' : 'YYYY-MM-DD';
$data->{DATEFORMATE} = $account->{dateFormat} eq 'US'? 'mm+"-"+dd+"-"+y' : $account->{dateFormat} eq 'EU'? 'dd+"-"+mm+"-"+y' : 'y+"-"+mm+"-"+dd';
print "Content-type: text/html\n\n";
my $content=$account->tmpToHtml($account->{tmpAccountForm},$data);
my $navLine = qq~<a href="$script">Accounts</a>&nbsp;&nbsp;/&nbsp;&nbsp;<b>Add new User</b>~;
print $account->toHtml(
CONTENT=>$content,
TITLE=>$account->{MESSAGES}->{clientmanager_newuser},
NAVIGATION => $navLine,
);
}
sub user{
my $userInfo = $account->getUserInfo($account->{CGI}->{id});
$userInfo->{diskquota}||='';
my $groups = $account->getList(
table=>$account->{tblGroups},
sort=>'name',
);
$userInfo->{groups}="";
for(@$groups){
$userInfo->{groups}.=qq~ <li><label><input type="checkbox" name="group" value="$_->{id}" ~.($userInfo->{userGroups}->{$_->{id}}? 'checked':'').($userInfo->{id} eq $account->currentUser->{id} && $_->{name} eq 'admin'  && $userInfo->{userGroups}->{$_->{id}} ? " onclick='return false;'":'' ).qq~> $_->{name}</label></li>~;
}
if ($userInfo->{limitdays}){ $userInfo->{'limitdays#'.$userInfo->{limitdays}} = 'selected';}
$userInfo->{expired} = $account->formatDate($userInfo->{expired});
$userInfo->{DATEFORMAT}  = $account->{dateFormat} eq 'US'? 'MM-DD-YYYY' : $account->{dateFormat} eq 'EU'? 'DD-MM-YYYY' : 'YYYY-MM-DD';
$userInfo->{DATEFORMATE}  = $account->{dateFormat} eq 'US'? 'mm+"-"+dd+"-"+y' : $account->{dateFormat} eq 'EU'? 'dd+"-"+mm+"-"+y' : 'y+"-"+mm+"-"+dd';
$userInfo->{disabled_1} = 'disabled' if ($userInfo->{id} eq $account->currentUser->{id});
print "Content-type: text/html\n\n";
my $content=$account->tmpToHtml($account->{tmpAccountFormEdit},$userInfo);
my $navLine = qq~<a href="$script">Accounts</a>&nbsp;&nbsp;/&nbsp;&nbsp;<b>$userInfo->{login}</b>~;
print $account->toHtml(
CONTENT=>$content,
TITLE=>"Client Manager :: $userInfo->{login}",
NAVIGATION => $navLine,
);
}
sub infoUser {
print "Content-type: text/html\n\n";
my $userInfo = $account->getUserInfo($account->{CGI}->{account});
$userInfo->{diskquota}||='&#8734;';
$userInfo->{expired} = '&#8734;' if $userInfo->{expired} eq '00-00-0000';
$userInfo->{expired} ||='&#8734;';
$userInfo->{deleteBtn}='disabled' if $userInfo->{id} eq $account->currentUser->{id};
$userInfo->{expired} = $account->formatDate($userInfo->{expired}) if $userInfo->{expired} ne '&#8734;';
my $content = $userInfo->{id}? $account->tmpToHtml($account->{tmpAccountDetails}, $userInfo) : "<div align=\"center\" class=\"error\"><br><br><br><b>$account->{MESSAGES}->{usernotfound}</b><br><br><a href=\"javascript:history.back();\"><b>$account->{MESSAGES}->{back}</b></a></div>";
my $user = $userInfo->{id}? $userInfo->{login} : "Account Details!";
my $navLine = qq~<a href="$script">Accounts</a>&nbsp;&nbsp;/&nbsp;&nbsp;<b>$user</b>~;
print $account->toHtml(
CONTENT=>$content,
TITLE=>'Client Manager :: '.$user,
NAVIGATION => $navLine);
}
sub groups {
if ($account->{CGI}->{delete}  && $account->{CGI}->{delete}!=1){
$account->deleteGroup($account->{CGI}->{delete});
print "Location: $script?action=groups\n\n";
return;
}
if ($account->{CGI}->{enable}){
$account->enableGroup($account->{CGI}->{enable});
print "Location: $script?action=groups\n\n";
return;
}
print "Content-type: text/html\n\n";
my $content = $account->showList(
table=>$account->{tblGroups},
template=>$account->{'tmpGroups'},
sort=>$account->{CGI}->{name} || 'id',
desc=>$account->{CGI}->{desc}
);
my $navLine = qq~<b>Groups</b>~;
print $account->toHtml(
CONTENT=>$content,
TITLE=>$account->{MESSAGES}->{clientmanager_groups},
NAVIGATION => $navLine);
}
sub newGroup {
my ($res, $data) = $account->createGroup() if $account->{CGI}->{submit};
if ($res){
print "Location: $script?action=groupinfo&id=$res\n\n";
return;
}
print "Content-type: text/html\n\n";
$data = $account->getGroupInfo($account->{CGI}->{id}) if $account->{CGI}->{id} && !$account->{CGI}->{submit};
my $content=$account->tmpToHtml($account->{tmpGroupForm},$data);
my $navLine = qq~<a href="$script?action=groups">Group</a>&nbsp;&nbsp;/&nbsp;&nbsp;<b>Add new Group</b>~;
if ($account->{CGI}->{id}){
$navLine = qq~<a href="$script?action=groups">Group</a>&nbsp;&nbsp;/&nbsp;&nbsp;<a href="$script?action=groupinfo&id=$data->{id}">$data->{name}</a>&nbsp;&nbsp;/&nbsp;&nbsp;<b>Edit</b>~;
}
print $account->toHtml(
CONTENT=>$content,
TITLE=>$account->{CGI}->{id}? "Client Manager :: Groups :: $data->{name}": $account->{MESSAGES}->{clientmanager_addnewgroups},
NAVIGATION => $navLine,
);
}
sub groupInfo{
print "Content-type: text/html\n\n";
my $info = $account->getGroupInfo($account->{CGI}->{id});
$info->{deleteDisabled} = "alert('$account->{MESSAGES}->{cannot_deleteadmingrp}'); return false;" if $info->{name}=~m/^admin?$/;
my $content = $info->{id}? $account->tmpToHtml($account->{tmpGroupDetails}, $info) : "<div align=\"center\" class=\"error\"><br><br><br><b>$account->{MESSAGES}->{groupnotfound}</b><br><br><a href=\"javascript:history.back();\"><b>$account->{MESSAGES}->{back}</b></a></div>";
my $navLine = qq~<a href="$script?action=groups">Groups</a>&nbsp;&nbsp;/&nbsp;&nbsp;<b>Group details</b>~;
print $account->toHtml(
CONTENT=>$content,
TITLE=>$account->{MESSAGES}->{clientmanager_groupsdetails},
NAVIGATION => $navLine);
}
sub folders {
if ($account->{CGI}->{delete}){
$account->deleteFolder($account->{CGI}->{delete});
print "Location: $script?action=folders\n\n";
return;
}
if ($account->{CGI}->{enable}){
$account->enableFolder($account->{CGI}->{enable});
print "Location: $script?action=folders\n\n";
return;
}
print "Content-type: text/html\n\n";
my $content = $account->showList(
table=>$account->{tblFolders},
template=>$account->{'tmpFolders'},
sort=>$account->{CGI}->{name} || 'id',
desc=>$account->{CGI}->{desc});
my $navLine = qq~<b>Shared Folders</b>~;
print $account->toHtml(
CONTENT=>$content,
TITLE=>$account->{MESSAGES}->{clientmanager_newuser},
NAVIGATION => $navLine);
}
sub newFolder {
my ($res, $data) = $account->createFolder() if $account->{CGI}->{submit};
if ($res){
print "Location: $script?action=folderinfo&id=$res\n\n";
return;
}
print "Content-type: text/html\n\n";
$data = $account->getFolderInfo($account->{CGI}->{id}) if $account->{CGI}->{id};
$data->{slimit} ||= '';
$data->{"disabled_".$data->{disabled}}='checked';
my $content=$account->tmpToHtml($account->{tmpFolderForm},$data);
my $navLine = qq~<a href="$script?action=folders">Shared Folders</a>&nbsp;&nbsp;/&nbsp;&nbsp;<b>Add new Folder</b>~;
if ($account->{CGI}->{id}){
$navLine = qq~<a href="$script?action=folders">Shared Folders</a>&nbsp;&nbsp;/&nbsp;&nbsp;<a href="$script?action=folderinfo&id=$data->{id}">$data->{name}</a>&nbsp;&nbsp;/&nbsp;&nbsp;<b>Edit</b>~;
}
print $account->toHtml(
CONTENT=>$content,
TITLE=>$account->{MESSAGES}->{clientmanager_sfolders},
NAVIGATION => $navLine,
);
}
sub folderInfo{
print "Content-type: text/html\n\n";
my $data = $account->getFolderInfo($account->{CGI}->{id});
$data->{"disabled_".$data->{disabled}}='checked';
my $content = $data->{id}? $account->tmpToHtml($account->{tmpFolderDetails}, $data) : "<div align=\"center\" class=\"error\"><br><br><br><b>$account->{MESSAGES}->{foldernotfound}</b><br><br><a href=\"javascript:history.back();\"><b>$account->{MESSAGES}->{back}</b></a></div>";
my $navLine = qq~<a href="$script?action=folders">Shared Folders</a>&nbsp;&nbsp;/&nbsp;&nbsp;<b>Folder</b>~;
print $account->toHtml(
CONTENT=>$content,
TITLE=>$account->{MESSAGES}->{clientmanager_sfoldersf},
NAVIGATION => $navLine,
);
}
sub rights{
my ($res, $data) = $account->createRights() if $account->{CGI}->{submit};
if ($res){
print "Location: $script?action=groupinfo&id=$account->{CGI}->{groupId}\n\n";
return;
}
print "Content-type: text/html\n\n";
my $info = $account->getGroupInfo($account->{CGI}->{group});
my @skip;
for(@{$info->{folderList}}){push @skip, $_->{id};}
$info->{'OPT#folderId'} = $account->getOpt($account->{tblFolders},undef,undef,\@skip);
$info->{'ACTION'} = 'rights';
$info->{'FORM_TITLE'}=$account->{MESSAGES}->{addftogroup};
my $content = $info->{id}? $account->tmpToHtml($account->{tmpRights}, $info) : "<div align=\"center\" ><br><br><br><b>$account->{MESSAGES}->{groupnotfound}</b><br><br><a href=\"javascript:history.back();\"><b>$account->{MESSAGES}->{back}</b></a></div>";
my $navLine = qq~<a href="$script">Groups</a>&nbsp;&nbsp;/&nbsp;&nbsp;<a href="$script?action=groupinfo&id=$info->{id}">$info->{name}</a>&nbsp;&nbsp;/&nbsp;&nbsp;<b>Add new folder</b>~;
unless ($info->{'OPT#folderId'}){
$content = "<div align=\"center\" class=\"error\"><br><br><br><b>$account->{MESSAGES}->{nofolder}</b><br><br><a href=\"javascript:history.back();\"><b>$account->{MESSAGES}->{back}</b></a></div>";
}
print $account->toHtml(
CONTENT=>$content,
TITLE=>"Client Manager :: Groups :: $info->{name}",
NAVIGATION => $navLine,
);
}
sub groupFolder {
my ($res, $data) = $account->createRights($account->{CGI}->{id}) if $account->{CGI}->{submit};
$res = $account->deleteRights($account->{CGI}->{id}) if $account->{CGI}->{delete};
if ($res){
print "Location: $script?action=groupinfo&id=$account->{CGI}->{groupId}\n\n";
return;
}
print "Content-type: text/html\n\n";
my $info = $account->getGroupInfo($account->{CGI}->{groupId});
my $rights = $account->getFolderRights($account->{CGI}->{groupId},$account->{CGI}->{folder});
$rights->{'OPT#folderId'} = $account->getOpt($account->{tblFolders},undef,$account->{CGI}->{folder});
$rights->{'group'}=$rights->{groupId};
$rights->{'name'}=$info->{'name'};
$rights->{'ACTION'} = 'groupFolder';
$rights->{'FORM_TITLE'}=$account->{MESSAGES}->{editfingroup};
$rights->{'BTN_Remove'}= qq~<input type="submit" name="delete" value="$account->{MESSAGES}->{remove_folderfromgp} $info->{'name'}" onclick="return confirm('$account->{MESSAGES}->{sure_removefoldergrp}')">~;
my $content = $info->{id}? $account->tmpToHtml($account->{tmpRights}, $rights) : "<div align=\"center\" class=\"error\"><br><br><br><b>$account->{MESSAGES}->{groupnotfound}</b><br><br><a href=\"javascript:history.back();\"><b>$account->{MESSAGES}->{back}</b></a></div>";
my $navLine = qq~<a href="$script">Groups</a>&nbsp;&nbsp;/&nbsp;&nbsp;<a href="$script?action=groupinfo&id=$rights->{groupId}">$info->{name}</a>&nbsp;&nbsp;/&nbsp;&nbsp;<b>Edit</b>~;
print $account->toHtml(
CONTENT=>$content,
TITLE=>"Client Manager :: Groups :: $info->{name}",
NAVIGATION => $navLine,
);
}
sub log{
print "Content-type: text/html\n\n";
my $info=$account->parseLog(user=>$account->{CGI}->{searchuser});
my $tmp = $account->read_file($account->{templateDir}."/".$account->{tmpLog});
$tmp=~/(.*)<template>(.*)<\/template>(.*)/s;
my (@tmpl) = ($1,$2,$3);
my $text = $tmpl[0];
my $count=0;
my @show = @{$info}[$account->{logRecordPerPage}*$account->{CGI}->{page}..($account->{logRecordPerPage}*($account->{CGI}->{page}+1)-1)];
for (@show){
next unless $_;
$text .= $account->get_record($tmpl[1],$_);
}
$text .= $tmpl[2];
my $nav = "<br><a href=\"$account->{SCRIPT}?action=log&searchuser=$account->{CGI}->{searchuser}&page=".($account->{CGI}->{page}-1)."\"><b>[$account->{MESSAGES}->{previous}]</b></a>" if $account->{CGI}->{page}>0;
$nav .= "&nbsp;&nbsp;<a href=\"$account->{SCRIPT}?action=log&searchuser=$account->{CGI}->{searchuser}&page=".($account->{CGI}->{page}+1)."\"><b>[$account->{MESSAGES}->{next}]</b></a><br>" if $account->{CGI}->{page}*50<@{$info} && @{$info}>50;
my $opt = '<form method="post" action="'.$script.'"><input type="hidden" name="action" value="log"><a class="clientmanager">'.$account->{MESSAGES}->{client_username}.'</a>:
<input type="text" name="searchuser" value="'.HTML::Entities::decode_entities($account->{CGI}->{searchuser}).'"> <input type="submit" value='.$account->{MESSAGES}->{search}.'></form>';
print $account->toHtml(
CONTENT=>$account->get_record($text, {pager=>$nav,searchuser=>$account->{CGI}->{searchuser}}),
TITLE=>$account->{MESSAGES}->{clientmanager_accounts},
NAVIGATION => '<b>Log</b>',
SELECTOR=>$opt,
);
}
sub logout {
$account->logout;
}
exit;
