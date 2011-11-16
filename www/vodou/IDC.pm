package IDC;
use strict;
#use lib './';
#************************************************************************************
#Build 1011A0001
#************************************************************************************
use Data::Dumper;
use File::Path;
use URI::Escape;
use DBI;
#use utf8;
our $languageFile = {
"en" => "English.ini",
"fr" => "French.ini",
"de" => "German.ini",
"it" => "Italian.ini",
"es" => "Spanish.ini",
"nl" => "Dutch.ini",
"sv" => "Swedish.ini",
"nb" => "Norsk.ini",
"fi" => "Finnish.ini",
"pt" => "Portuguese.ini",
"pt-br" => "Portuguese (BR).ini",
"ru" => "Russian.ini"
};
#our $languageFile = {
#"en" => "English.ini",
#"fr" => "French.ini",
#"de" => "German.ini",
#"nl" => "Dutch.ini",
#"it" => "Italian.ini",
#"es" => "Spanish.ini",
#"da" => "Dansk.ini",
#"sv" => "Swedish.ini",
#"nb" => "Norsk.ini",
#"fi" => "Finnish.ini",
#"pt" => "Portuguese (BR).ini",
#"ru" => "Russian.ini"
#};
sub login{
my $self = shift;
my $args = {
password=>undef,
login =>undef,
@_
};
$ENV{HTTP_ACCEPT_LANGUAGE}=~/^(en|fr|de|it|es|nl|sv|nb|fi|pt|pt-br|ru)/;
$self->{CGI}->{language} ||= $1;
$self->{CGI}->{language} = 'en' unless $languageFile->{$self->{CGI}->{language}};
my $lang = $self->{CGI}->{language} || 'en';
$self->getMessages( $lang ) if (!$self->{MESSAGES} or !scalar(%{$self->{MESSAGES}}));
$self->{CGI}->{login}=undef;
$self->{CGI}->{password}=undef;
my $user = $self->getUser($args->{login});
if ($user->{id} && $self->checkPassword($args->{password},$user->{password}) && !$user->{disabled}){
if ( $self->validTime($user)){
$self->currentUserBySid($user->{login});
return $self->{currentUser} = $user;
}
else{
$args->{message}= $self->{MESSAGES}->{expired_err};
$args->{forgott_password}= $self->{MESSAGES}->{forgott_password};
$args->{error} = qq~<script type="text/javascript">\nshowLogin('$self->{CGI}->{type}','$lang')\n</script>~;
}
}
elsif($args->{login}) {
$args->{message}= $self->{MESSAGES}->{login_err};
$args->{forgott_password}= $self->{MESSAGES}->{forgott_password};
$args->{error} = qq~<script type="text/javascript">\nshowLogin('$self->{CGI}->{type}','$lang')\n</script>~;
$self->log($self->{logActivity},"Invalid login attempt user: $args->{login}") if $self->{logActivityOn};
}
elsif($args->{forgott}){
$args->{message}= $self->{MESSAGES}->{$args->{forgott}};
$args->{error} = qq~<script type="text/javascript">\nshowLogin(0,'$lang')\n</script>~;
}
$args->{'selected_'.$lang}='selected';
my $content=$self->tmpToHtml('tmpLogin.html',$args);
print "Content-type: text/html\n\n";
print $content;
exit;
}
sub new{
my $class = shift;
my $self = {};
bless ($self, $class);
$self -> _Init(@_);
return $self;
}
sub _Init
{
my $self = shift;
if(@_){
my %arg = @_;
if ($arg{config}){
$self->_LoadConfig($arg{config});
$self->_LoadConfig($self->{alternativeConfigurationFile}) if $self->{alternativeConfigurationFile};
}
@$self{keys %arg} = values %arg;
}
$self->connectDb();
return $self;
}
sub _LoadConfig{
my $self = shift;
my $file = shift;
die "Can't load Configuration file - $!" unless -f $file;
open(CONF, $file) || $self->error("can't open file $file!");
my @conf = <CONF>;
close CONF;
for (@conf){
$_=~s/^\s+//;
$_=~s/\s+(\r|\n)//g;
next if !$_;
next if $_=~m/^\#/;
$_=~m/^([^\s]+)\s+?['"]*([^\s].*?)['"]*$/;
$self->{$1} = $2;
}
for (split(',', $self->{hideFiles})) {$self->{hiddenFiles}->{$_}=1;}
for (split(',', $self->{disabledFiles})){$self->{disabledFileList}->{$_}=1;};
}
sub parseCGI{
my $self = shift;
#use utf8;
#use HTML::Entities;
#use Encode;
my %FORM;
$ENV{'QUERY_STRING'} =~s/&amp;/&/g;
my @pairs=split(/&/,$ENV{'QUERY_STRING'});
foreach  my $pair (@pairs) {
my ($name,$value)= split (/=/,$pair,2);
$value=~tr/+/ /;
$value=~ s/%(..)/pack("c",hex($1))/ge;
$value =~ s/<!--(.|\n)*-->//g;
$value =~ s/<([^>]|\n)*>//g;
#$value =HTML::Entities::decode_entities($value);
if ($FORM{$name}){
if(ref $FORM{$name} eq 'ARRAY'){ push @{$FORM{$name}}, $value;}
else{
my $tmp = $FORM{$name};
$FORM{$name}=[];
push @{$FORM{$name}}, $tmp;
push @{$FORM{$name}}, $value;
}
}
else {$FORM{$name} = $value;}
}
#die Dumper(\%FORM);
###########################
if ($ENV{'CONTENT_TYPE'} =~ m/multipart\/form-data/i){
if ($FORM{action} ne 'upload'){
require CGI;
my @params=CGI::param();
for(@params){
        ($FORM{$_}=CGI::param($_))=~ s/<([^>]|\n)*>//g;
}
}
}
else{
read(STDIN, my $buffer, $ENV{'CONTENT_LENGTH'});
my @pairs = split(/&/, $buffer);
foreach my $pair (@pairs) {
my ($name, $value) = split(/=/, $pair);
$value =~ tr/+/ /;
$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
if ($name ne 'content'){
$value =~ s/<!--(.|\n)*-->//g;
$value =~ s/<([^>]|\n)*>//g;
}
if ($FORM{$name}){
if(ref $FORM{$name} eq 'ARRAY'){ push @{$FORM{$name}}, $value;}
else{
my $tmp = $FORM{$name};
$FORM{$name}=[];
push @{$FORM{$name}}, $tmp;
push @{$FORM{$name}}, $value;
}
}
else {$FORM{$name} = $value;}
}
}
for('dir','file','gzfile'){
$FORM{$_}=~s/\.\.\/?|~\/?//g;
}
$self->{CGI}=\%FORM;
return %FORM;
}
sub getParam{
my $self = shift;
my $key = shift;
if (ref $self->{CGI}->{$key} eq 'ARRAY'){
return @{$self->{CGI}->{$key}};
}
else{return $self->{CGI}->{$key};}
}
sub connectDb{
my $self = shift;
my $args={
dns=>undef,
user=>undef,
password=>undef,
@_,
};
my $dbh = DBI->connect(
$args->{dns} || $self->{dns},
$args->{user} || $self->{dbUser},
$args->{password} || $self->{dbPassword}
);
unless(defined $dbh){
die "$DBI::errstr\n";
}
$self->dbh($dbh);
return $dbh;
}
sub dbh{
my $self = shift;
my $dbh=shift;
if (defined $dbh){$self->{'dbh'}=$dbh;}
die "Can't use uninitialized connection!" unless $self->{'dbh'};
return $self->{'dbh'};
}
sub disconnect{
my $self = shift;
$self->dbh->disconnect;
}
sub createRecord{
my $self = shift;
my $args = {
table=>undef,
data=>undef,
@_
};
my @values;
for (keys %{$args->{data}}){
if ($_ eq 'expired' && !$args->{data}->{$_}){push @values,'NULL';}
else{push @values, $self->dbh->quote($args->{data}->{$_});}
}
$self->dbh->do("INSERT INTO $args->{table} (". join(',',keys %{$args->{data}} ). ") VALUES (".join(',',@values).")") or die $self->dbh->errstr;
my $sth=$self->dbh->prepare('SELECT LAST_INSERT_ID()');
$sth->execute or die $self->dbh->errstr;
my ($id)=$sth->fetchrow_array;
$sth->finish;
return $id;
}
sub updateRecord{
my $self = shift;
my $args={
table => undef,
id => undef,
data => undef,
@_,
};
my @values;
for(keys %{$args->{data}}){
push @values, "$_ = ".$self->dbh->quote($args->{data}->{$_});
}
$self->dbh->do("UPDATE $args->{'table'} SET ".join(',',@values)." WHERE id=".$self->dbh->quote($args->{'id'})) || die $self->dbh->errstr;
}
sub getRecord{
my $self = shift;
my $args = {
table=>undef,
id=>undef,
@_
};
my $sth=$self->dbh->prepare("SELECT * FROM  $args->{table} WHERE id=?");
$sth->execute($args->{id}) or die $self->dbh->errstr;
my $href = $sth->fetchrow_hashref;
return $href;
}
sub getRecordByCol{
my $self = shift;
my $args = {
table=>undef,
col=>undef,
value=>undef,
order => undef,
@_
};
my $sth=$self->dbh->prepare("SELECT * FROM  $args->{table} WHERE $args->{col}=? $args->{order}");
$sth->execute($args->{value}) or die $self->dbh->errstr;
my $href = $sth->fetchrow_hashref;
return $href;
}
sub getList{
my $self = shift;
my $args = {
table=>undef,
sort=>undef,
desc=>undef,
page=>0,
rowsPerPage=>undef,
field=>undef,
value=>undef,
operator=>'=',
@_
};
for (keys %$args){next if $_ eq 'value'; $args->{$_}=~s/\s.*//; }
my $sort = "ORDER BY $args->{sort} ". ($args->{desc}? 'DESC':'') if $args->{sort};
my $where = "WHERE $args->{field}  $args->{operator}".$self->dbh->quote($args->{value}) if $args->{value} && $args->{field};
my $statement = "SELECT * FROM  $args->{table} $where $sort";
if ($args->{rowsPerPage}){
my $sth=$self->dbh->prepare("SELECT COUNT(1) FROM  $args->{table} $where");
$sth->execute() or die $self->dbh->errstr;
(my $count) = $sth->fetchrow_array;
$self->{_pager}="";
$args->{'page'} ||=0;
for(0..int($count%$args->{rowsPerPage}? $count/$args->{rowsPerPage}:$count/$args->{rowsPerPage}-1)){
if ( $args->{'page'} eq $_ ){
$self->{'_pager'} .= " [". ($_ + 1) . "] ";
}
else { $self->{_pager} .= " <a href='$self->{SCRIPT}?group=$self->{CGI}->{group}&sort=$self->{CGI}->{sort}&desc=$self->{CGI}->{desc}&page=$_'> ". ($_ + 1) . "</a> ";}
}
}
my $limit = "$args->{'rowsPerPage'}" if $args->{'rowsPerPage'};
$limit &&= $args->{'page'}*$args->{'rowsPerPage'} .",$limit" if $args->{'page'};
$statement .= " LIMIT $limit" if $limit;
my $sth=$self->dbh->prepare($statement);
$sth->execute() or die $self->dbh->errstr;
my $result = [];
while (my $row = $sth->fetchrow_hashref){
$row->{disabled}&&=$self->{MESSAGES}->{yes};
push @$result,$row;
}
$sth->finish;
return $result;
}
sub deleteRecord{
my $self = shift;
my $args = {@_};
$self->dbh->do("DELETE FROM $args->{table} where $args->{field}=".$self->dbh->quote($args->{value})) or die $self->dbh->errstr;
}
sub getJoinedList{
my $self = shift;
my $args = {
table=>undef,
alias=>undef,
fieldId=>undef,
fieldValue=>undef,
sort=>undef,
joinedOn=>undef,
desc=>undef,
@_
};
my $sort = "ORDER BY $args->{sort}". ($args->{desc}? ' DESC':'') if $args->{sort};
my $statement = "SELECT a.* FROM $args->{table} a LEFT JOIN $args->{alias} b on  b.$args->{joinedOn} = a.id WHERE b.$args->{fieldId}=? $sort";
#die $statement. " $args->{fieldValue}" if $args->{table} eq $self->{tblAccounts};
my $sth=$self->dbh->prepare($statement);
$sth->execute($args->{fieldValue}) or die $self->dbh->errstr;
my $result = [];
while (my $row = $sth->fetchrow_hashref){
$row->{disabled}&&=$self->{MESSAGES}->{yes};
push @$result,$row;
}
$sth->finish;
return $result;
}
sub getMessages{
my $self = shift;
my $lang = shift;
my $Mess;
if ($lang ne 'en'){
open (MESS, "$self->{languageMessagesFolder}/$languageFile->{'en'}") or die "Cannot Open Lanaguage File $self->{languageMessagesFolder}/$languageFile->{$lang} $!";
my @data=<MESS>;
close MESS;
for (@data){
chomp;
$_=~s/\r//gs;
my ($key,$value) = split("==",$_);
$Mess->{$key}=$value;
}
}
open (MESS, "$self->{languageMessagesFolder}/$languageFile->{$lang}") or die "Cannot Open Lanaguage File $self->{languageMessagesFolder}/$languageFile->{$lang} $!";
my @data=<MESS>;
close MESS;
for (@data){
chomp;
$_=~s/\r//gs;
my ($key,$value) = split("==",$_);
$Mess->{$key}=$value;
}
$self->{MESSAGES}=$Mess;
}
sub forgott{
        my $self=shift;
        my $res = $self->getRecordByCol(table=>$self->{tblAccounts}, col=>'email', value=>$self->{CGI}->{email});
        if ($res && $res->{id} && $res->{email}){
        $self->{currentUser}->{id}=$res->{id};
        $self->{currentUser}->{limitdays}=$res->{limitdays};
        my $newPass = $self->generatePassword();
        $self->updatePassword($newPass,1);
        undef $self->{currentUser};
        $res->{password}=$newPass;
        $self->getMessages( $self->{currentUser}->{language}  || 'en');
        my $message = $self->get_record($self->read_file($self->{templateDir}."/".$self->{msgForgottPassword}),$res);
        $self->male($res->{email}, $self->{fromAdmin}, 'Password Reminder', $message );
        $self->login(forgott=>'forgott_ok');
        }
        else{$self->login(forgott=>'forgott_err');}
}
sub restore{
        my $self=shift;
        my $res = $self->getRecordByCol(table=>$self->{tblAccounts}, col=>'email', value=>$self->{CGI}->{email});
        if ($res && $res->{id} && $res->{email}){
        $self->{currentUser}->{id}=$res->{id};
        $self->{currentUser}->{limitdays}=$res->{limitdays};
        my $newPass = $self->generatePassword();
        $self->updatePassword($newPass,1);
        undef $self->{currentUser};
        $res->{password}=$newPass;
        $self->getMessages( $self->{currentUser}->{language}  || 'en');
        my $message = $self->get_record($self->read_file($self->{templateDir}."/".$self->{msgAccountRestore}),$res);
        $self->male($res->{email}, $self->{fromAdmin}, 'Account Restore', $message );
        $self->login(forgott=>'forgott_ok');
        }
        else{$self->login(forgott=>'forgott_err');}
}
sub currentUserBySid{
my $self = shift;
my $login = shift;
use CGI::Cookie;
use Session;
my $sid = $self->getCookie($self->{cookieName});
my $session;
if ($sid && -f  $self->{sessionDir}."/cgisess_".$sid){
#exist session
$session = new Session($sid, {Directory=>$self->{sessionDir}}) or die CGI::Session->errstr;
}
else{
#create new session
$session = new Session(undef, {Directory=>$self->{sessionDir}}) or die CGI::Session->errstr;
$sid = $session->id();
my $cookie = new CGI::Cookie(-name=>$self->{cookieName},-value=>$sid);
print "Set-Cookie: $cookie\n";
}
#if like see $session:
#die Dumper($session);
if ($login){
$session->param('user', $login);
$session->param('language', $self->{CGI}->{language}||'en');
return $sid;
}
else {
return $self->{currentUser} = $self->getUser($session->param('user'), $session->param('language'));
}
}
sub logout{
my $self = shift;
my $error = shift;
unlink $self->{sessionDir}."/cgisess_".$self->getCookie($self->{cookieName});
my $c = new CGI::Cookie(
-name=>$self->{cookieName},
-value=>'',
-expires =>  '-1Y'
);
print "Set-Cookie: $c\n";
print "Location: $self->{SCRIPT}".($error? "?error=$error":'')."\n\n";
exit;
return;
}
sub clearSessions{
my $self = shift;
opendir(DIR, $self->{sessionDir}) or die "$!";
while (my $file=readdir(DIR)){
if ($file!~/^\./){
unlink "$self->{sessionDir}/$file" if -M  "$self->{sessionDir}/$file" > 1;
}
}
}
sub tmpToHtml{
my $self = shift;
my $tmp = shift;
my $args = shift;
my $html=$self->read_file("$self->{'templateDir'}/$tmp");
for (keys %{$self->{CGI}}){
if ($_ eq 'disables'){$args->{$_."_".$self->{CGI}{$_}} = 'checked';}
elsif ($_ eq 'rights'){
if (ref $self->{CGI}->{$_} eq 'ARRAY'){
for my $elem (@{$self->{CGI}->{$_}}){
$args->{$_."_".$elem} = 'checked';
}
}
else{$args->{$_."_".$self->{CGI}->{$_}} = 'checked';}
}
else{$args->{$_} = $self->{CGI}->{$_};}
}
$args->{htmlDataFolder}=$self->{htmlDataFolder};
for (keys %{$self->{MESSAGES}}){
$args->{'MESS#'.$_}=$self->{MESSAGES}->{$_};
}
return $self->get_record($html,$args);
}
sub toHtml{
my $self = shift;
my $args = {
content=>undef,
navigation=>undef,
title=>undef,
userData=>undef,
@_
};
$args->{userData} = {
login=> $self->currentUser->{login},
groups=> ref $self->currentUser->{groups} eq 'ARRAY'? join(', ',@{$self->currentUser->{groups}}):'',
} if !$args->{userData} && $self->currentUser;
#userData
if (ref $args->{userData} eq 'HASH'){
for (keys %{$args->{userData}}){
$args->{'#'.$_}=$args->{userData}->{$_};
}
}
#customLink
for(1..6){
$args->{'customLink'.$_}=$self->{'customLink'."$_"};
}
for (keys %{$self->{MESSAGES}}){
$args->{'MESS#'.$_}=$self->{MESSAGES}->{$_};
}
$args->{LogActivityLink} = "<a class=\"clientmanager\" href=\"$self->{SCRIPT}?action=log\">$self->{MESSAGES}->{show_log}</a>" if $self->{logActivityOn};
$args->{timeOutScript} = qq~onMouseMove="ResetIdle()" onKeyPress="ResetIdle();"  onLoad=" ResetIdle();"~  if $self->{timeOut};
$args->{timeOut} =  $self->{timeOut};
$args->{htmlDataFolder} =  $self->{htmlDataFolder};
my $tmp=$self->read_file("$self->{'templateDir'}/$self->{'tmpAccountsMain'}");
return  $self->get_record($tmp,$args);
}
sub get_record{
my $self = shift;
my $text = shift;
my $INSERT = shift;
$INSERT->{SkinFolder} ||= $self->{SkinFolder};
$INSERT->{SCRIPT} ||= $self->{SCRIPT};
$INSERT->{htmlDataFolder} ||= $self->{htmlDataFolder};
$INSERT->{htmlLogoFolder} ||= $self->{htmlLogoFolder};
$INSERT->{htmlTemplateFolder} ||= $self->{htmlTemplateFolder};
$INSERT->{scriptPath} ||= $self->{scriptPath};
$INSERT->{RegisteredOwner} ||= $self->{RegisteredOwner};
$INSERT->{Filemanagertitle} ||= $self->{Filemanagertitle};
$INSERT->{FileManagerName} ||= $self->{FileManagerName};
$INSERT->{clientroot} ||= $self->{clientroot};
$INSERT->{ShowSignupOption} ||= $self->{ShowSignupOption};
$INSERT->{TopBar} ||= $self->{TopBar};
$INSERT->{FilterBar} ||= $self->{FilterBar};
$INSERT->{ControlBarIcon} ||= $self->{ControlBarIcon};
$INSERT->{CentralBox} ||= $self->{CentralBox};
$INSERT->{TaskbarLogin} ||= $self->{TaskbarLogin};
$INSERT->{LargeFileManagerLogo} ||= $self->{LargeFileManagerLogo};
$INSERT->{LoginFM} ||= $self->{LoginFM};
$INSERT->{LoginCM} ||= $self->{LoginCM};
$INSERT->{LoginHelp} ||= $self->{LoginHelp};
$INSERT->{FileManagerLogo} ||= $self->{FileManagerLogo};
$INSERT->{ClientManagerLogo} ||= $self->{ClientManagerLogo};
$INSERT->{Dottedline} ||= $self->{Dottedline};
$INSERT->{Tbleft} ||= $self->{Tbleft};
$INSERT->{Tbright} ||= $self->{Tbright};
$INSERT->{Formbg} ||= $self->{Formbg};
$INSERT->{MainBackground} ||= $self->{MainBackground};
$INSERT->{ClientScriptName} ||= $self->{ClientScriptName};
$INSERT->{FileManagerScriptName} ||= $self->{FileManagerScriptName};
$INSERT->{AccountCreationScriptName} ||= $self->{AccountCreationScriptName};
for (keys %{$self->{MESSAGES}}){
$INSERT->{'MESS#'.$_}=$self->{MESSAGES}->{$_};
}
$text =~ s{%%(.*?)%%}{exists($INSERT->{$1}) ? $INSERT->{$1} : ""}gsex;
return $text;
}
sub read_file{
my $self = shift;
my $file = shift;
my $binmode = shift;
local $/;
open(F, $file) || die("Can't open file $file!");
binmode F if $binmode;
my $data = <F>;
close F;
return $data;
}
sub male{
my $self = shift;
my $text = $_[3];
my $subject = $_[2];
if ($text=~s/^Subject: (.*?)[\r|\n]+//){$subject =  $1 }
if ($self->{sendSMTP}){
require Net::SMTP;
my $smtp = Net::SMTP->new($self->{mailHostSMTP});
$smtp->auth($self->{AuthenticationUsername}, $self->{AuthenticationPassword}) if $self->{EmailAuthenticationON};
$smtp->mail($_[1]);
$smtp->to($_[0]);
$smtp->data();
$smtp->datasend("To: $_[0]\n");
$smtp->datasend("From: $_[1]\n");
$smtp->datasend("Content-type: text/html\n") if $text=~m/<html>|<\!DOCTYPE/i;
$smtp->datasend("Subject: $subject\n\n");
$smtp->datasend("\n");
$smtp->datasend("$text\n");
$smtp->dataend();
$smtp->quit;
}
else{
open(MAIL,"|$self->{sendMailPath} -t");
print MAIL "To: $_[0]\n";
print MAIL "From: $_[1]\n";
print MAIL "Content-type: text/html\n" if $text=~m/<html>|<\!DOCTYPE/i;
print MAIL "Subject: $subject\n\n";
print MAIL "$text\n";
close(MAIL);
}
}
sub getUser{
my $self = shift;
my $login = shift;
my $language = shift;
my $info=$self->getRecordByCol(table=>$self->{tblAccounts}, col=>'login', value=>$login);
return $info if !$info->{id} || $info->{disabled};
$info->{RIGHTS}={};
my @rights = split(',',$info->{rights});
for (@rights){
$info->{RIGHTS}->{$_}=1;
$info->{RIGHTS_BOX}->{$_}='checked';
}
$info->{language}=$language;
$info->{protect}=~s/\s//g;
for(split(',',$info->{protect})){$info->{PROTECT}->{$_}=1;}
my $groups = $self->getJoinedList(
table=>$self->{tblGroups},
alias=>$self->{tblUserGroup},
joinedOn=>'groupId',
fieldId=>'userId',
fieldValue=>$info->{id},
);
my $isAdmin;
$info->{groups}=[];
if (@$groups){
my @grpId;
my %grpEml;
for (@$groups){
push @grpId, $_->{id};
$isAdmin=1 if $_->{name} eq 'admins' or $_->{name} eq 'admin';
push @{$info->{groups}},$_->{name};
$grpEml{$_->{id}}=$_->{groupemail};
}
my $statement = "SELECT f.*, gf.groupId,gf.rights,gf.useCustomProtect,gf.protect
FROM $self->{tblFolders} f LEFT JOIN $self->{tblGroupFolder} gf on gf.folderId=f.id
WHERE gf.groupId in (".(join ",",@grpId).") AND (f.disabled=0 OR f.disabled is NULL)";
my $sth=$self->dbh->prepare($statement);
$sth->execute() or die $self->dbh->errstr;
my $result = {};
while (my $row = $sth->fetchrow_hashref){
$result->{$row->{name}}->{RIGHTS}={};
for (split(',',$row->{rights})){
$result->{$row->{name}}->{RIGHTS}->{$_}=1;
}
my $dis = delete $row->{useCustomProtect};
my $ext = delete $row->{protect};
if ($dis){
$ext=~s/\s//g;
for(split(',',$ext)){
#TODO only summ
$result->{$row->{name}}->{PROTECT}->{$_}=1;
}
}
for('path','description','id','groupId','slimit'){$result->{$row->{name}}->{$_}=$row->{$_};}
$result->{$row->{name}}->{groupemail}=$grpEml{$row->{groupId}};
}
$sth->finish;
$info->{'SHARED'}=$result;
$info->{'isAdmin'}=$isAdmin;
}
$self->{'clientroot'} = $isAdmin? $self->{'clientroot'}:$self->{'clientroot'}."/".$info->{'home'};
$self->{currentUser}->{'clientroot'}=$self->{'clientroot'};
return $info;
}
sub currentUser{
        my $self=shift;
        my $login=shift;
        if ($login){
        $self->{currentUser} = $self->getUser($login);
        }
        $self->{currentUser} = undef if !$self->{currentUser} or !scalar %{$self->{currentUser}};
        return $self->{currentUser};
}
sub sendToGroup{
        my $self=shift;
        my $args={@_};
        my $users = $self->getJoinedList(
        table=>$self->{tblAccounts},
        alias=>$self->{tblUserGroup},
        joinedOn=>'userId',
        fieldId=>'groupId',
        fieldValue=>$args->{group},
        sort=>'login',
        );
        for (@$users){
        next if $_->{email} eq $self->currentUser->{email};
        next if $_->{email} eq $self->{toAdmin};
        $self->male(
        $_->{email},
        $self->currentUser->{email} || $self->{fromAdmin},
        $args->{subject},
        $args->{message}
        );
        }
}
sub validTime{
my $self=shift;
my $user = shift || $self->{currentUser};
my $time=$user->{expired};
use Time::Local;
if (!$time || $time=~m/^0000-00-00/){ return 1;}
else{
my ($yy,$mm,$dd)=(split/-/,$time)[0,1,2];
$yy-=1900;
$mm--;
return 1 if timelocal(0,0,0,$dd,$mm,$yy)>time;
}
return 0;
}
sub getUserById{
my $self=shift;
my $id = shift;
my $res = $self->getRecord(table=>$self->{tblAccounts},
id=>$id);
return $self->currentUser($res->{login});
}
sub updateEmail{
my $self = shift;
my $eml = shift;
my $sth=$self->dbh->prepare("UPDATE $self->{tblAccounts} SET email=? WHERE id=$self->{currentUser}->{id}");
$sth->execute($eml) or die $self->dbh->errstr;
$self->{currentUser}->{email}=$eml;
return 1;
}
sub checkPassword{
my $self = shift;
my $pass = shift;
my $saved = shift;
return $saved eq  crypt($pass,$saved)? 1:0;
}
sub updatePassword{
        my $self = shift;
        my $pass = shift;
        my $flag = shift;
        $pass =  $self->cryptPass($pass);
        my $add;

        if ($flag && $self->{autoExpireAfter}){
        my ($dd,$mm,$yy) = (localtime(time()+$self->{autoExpireAfter}*24*60*60))[3,4,5];
                $add=",expired='".sprintf("%04D-%02D-%02D", $yy+1900,$mm+1,$dd)."'";
        }

        my $sth=$self->dbh->prepare("UPDATE $self->{tblAccounts} SET password=? $add WHERE id=$self->{currentUser}->{id}");
        $sth->execute($pass) or die $self->dbh->errstr;
        $self->{currentUser}->{password}=$pass;
        return 1;
}
sub cryptPass{
my $self = shift;
my $password = shift;
my $string = "qwertzuiopasdfghjklyxcvbnmQWERTZUIOPASDFGHJKLYXCVBNM";
my @chars=split(//,$string);
my $crypt = $chars[int(rand(@chars-1))].$chars[int(rand(@chars-1))];
return crypt($password,$crypt);
}
sub generatePassword{
my $self = shift;
my $password = shift;
my $string = "qwertzuiopasdfghjklyxcvbnmQWERTZUIOPASDFGHJKLYXCVBNM1234567890";
my @chars=split(//,$string);
my $pass;
for(0..5){$pass.=$chars[int(rand(@chars-1))];}
return $pass;
}
sub getCookie{
my $self=shift;
my $id = shift;
my %COOK;
my @cookies=split('; ',$ENV{HTTP_COOKIE});
foreach my $line (@cookies){
my ($c_name, $c_value) = split(/=/,$line,2);
if ($c_name eq $id){
$c_value=~s/;$//;
return $c_value;
# my @cook=split(/&/,$c_value);
# for(my $x=0; $x<@cook; $x+=2){
#         $cook[$x+1] =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
#         $COOK{$cook[$x]}=$cook[$x+1];
# }
}
}
return undef;
}
sub getNotes{
my $self = shift;
my $file = shift;
$file=~s/\/$//;
my $info = $self->getList(
table=>$self->{tblNotes},
field=>'file',
value=>$file,
sort=>'',
);
return $info;
}
sub deleteNote{
my ($self,$file)=@_;
$self->dbh->do("DELETE FROM $self->{tblNotes} where file=".$self->dbh->quote($file) ) || die $DBI::errstr;
}
sub getNote{
my $self = shift;
my $file = shift;
return $self->getRecordByCol(table=>$self->{tblNotes}, col=>'file', value=>$file, order=>'');
}
sub moveNotes{
my $self = shift;
my $file = shift;
my $new = shift;
my $move = shift;
$file=~s/\/+/\//g;
$new=~s/\/+/\//g;
if ($move){
$self->dbh->do("UPDATE $self->{tblNotes} SET file=".$self->dbh->quote($new)." where file=".$self->dbh->quote($file) ) || die $DBI::errstr;
}
else{
my $sth=$self->dbh->prepare("SELECT userId,user,date,note FROM $self->{tblNotes} where file=".$self->dbh->quote($file) );
$sth->execute() || die $DBI::errstr;
my $sth2=$self->dbh->prepare("INSERT INTO $self->{tblNotes}  (userId,user,date,note,file) VALUES (?,?,?,?,?)");
while (my @row=$sth->fetchrow_array){
$sth2->execute(@row,$new) || die $DBI::errstr;
}
$sth->finish;
$sth2->finish;
}
if (-d $new){
if ($move){
my $sth=$self->dbh->prepare("SELECT id,file FROM $self->{tblNotes} where file like ".$self->dbh->quote($file."/%") );
$sth->execute() || die $DBI::errstr;
my $sth2=$self->dbh->prepare("UPDATE $self->{tblNotes} SET file =? where id=?");
while (my ($id,$oldfile)=$sth->fetchrow_array){
$oldfile=~s/^$file/$new/e;
$sth2->execute($oldfile,$id) || die $DBI::errstr;
}
$sth->finish;
$sth2->finish;
}
else{
my $sth=$self->dbh->prepare("SELECT id,file,userId,user,date,note FROM $self->{tblNotes} where file like ".$self->dbh->quote($file."/%") );
$sth->execute() || die $DBI::errstr;
my $sth2=$self->dbh->prepare("INSERT INTO $self->{tblNotes}  (file,userId,user,date,note) VALUES (?,?,?,?,?)");
while (my ($id,$oldfile, @row)=$sth->fetchrow_array){
$oldfile=~s/^$file/$new/e;
$sth2->execute($oldfile,@row) || die $DBI::errstr;
}
$sth->finish;
$sth2->finish;
}
}
}
sub saveNote{
my $self = shift;
my $args = {@_};
return unless $args->{file};
if ($args->{id}){
$self->dbh->do("UPDATE $self->{tblNotes} SET
note=".$self->dbh->quote($args->{note}).",
date=NOW()
WHERE id = ".$self->dbh->quote($args->{id})) or die $self->dbh->errstr;
}
else{
$self->dbh->do("INSERT INTO $self->{tblNotes} (userId,user,file,note,date)
VALUES ( ".($args->{userId} || $self->dbh->quote($self->currentUser->{id})).",".
$self->dbh->quote($args->{login} || $self->currentUser->{login}).",".
$self->dbh->quote($args->{file}).",".
$self->dbh->quote($args->{note}).",".($args->{date}? "'$args->{date}'":"NOW()").")" ) or die $self->dbh->errstr;
}
}
sub deleteNoteById{
my $self = shift;
my $id = shift;
return unless $id;
$self->dbh->do("DELETE FROM $self->{tblNotes}
WHERE id = ".$self->dbh->quote($id)) or die $self->dbh->errstr;
}
sub rmFolder{
my $self = shift;
my $path = shift;
File::Path::rmtree($path);
}
sub findNotes{
my $self = shift;
my $search = shift;
my $flag = shift;
$search =~s/'\///g;
my @files;
my $sth = $self->dbh->prepare("SELECT file FROM $self->{tblNotes} where note like '%$search%'");
$sth->execute();
while (my ($row)=$sth->fetchrow_array()){push @files, $row;}
return @files;
}
sub updateNotes{
my $self = shift;
my ($old,$new) = @_;
return unless $old || $new;
$old=~s/\/+/\//g;
$new=~s/\/+/\//g;
my $res = $self->getNotes($old);
for (@$res){
$self->dbh->do("UPDATE $self->{tblNotes} SET
file=".$self->dbh->quote($new)."
WHERE id = ".$self->dbh->quote($_->{id})) or die $self->dbh->errstr;
}
}
sub error{
my $self = shift;
my $mess = shift;
print "Content-Type: text/html;  charset=utf-8\n\n";
print qq~<html>\n<head>\n<title>ERROR</title>
<link rel="stylesheet" type="text/css" href="$self->{htmlDataFolder}/fm.css">
</head>
<body>
<div class="errbox">
<p class="error">$mess</p>
<input type="button" value="$self->{'MESSAGES'}->{back}" onclick="history.back() || window.close()">
</div>
</body>
</html>
~;
$self->log($self->{logActivity},$mess) if $self->{logActivityOn};
exit;
}
sub log{
my $self=shift;
my $file=shift;
my $message=shift;
my $time = localtime();
open (LOG, ">>$file") or die $! ."[$file]";
print LOG "$time|".($self->currentUser? $self->currentUser->{login} : 'Unauthorized')."|$message\n";
close(LOG);
}
sub formatDate{
my $self = shift;
my $date = shift;
my $back = shift;
return unless $date;
if ($self->{dateFormat} eq 'US'){# us 'MM-DD-YYYY'
if ($back){ return sprintf("%04D-%02D-%02D", (split '-',$date)[2,0,1]); }
else{return sprintf("%02D-%02D-%04D", (split '-',$date)[1,2,0]);}
}
if ($self->{dateFormat} eq 'EU'){# eu 'DD-MM-YYYY'
if ($back){ return sprintf("%04D-%02D-%02D", (split '-',$date)[2,1,0]); }
else{return sprintf("%02D-%02D-%04D", (split '-',$date)[2,1,0]);}
}
return $date;
}
sub parseLog {
my $self = shift;
my $args = {@_};
open (LOG, $self->{logActivity}) or die $!;
my @log = <LOG>;
close(LOG);
my $parsed =[];
for (@log){
$_=~s/\n|\r//g;
my @tmp = split '\|', $_;
next if $args->{user} && $tmp[1] ne $args->{user};
push @$parsed, {logdate=>$tmp[0],loguser=>$tmp[1],logaction=>$tmp[2]};
}
$parsed = [reverse @$parsed];
return $parsed;
}
1;
