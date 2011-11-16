package Account;
use strict;
#use lib './';
#************************************************************************************
#Build 1011A0001
#************************************************************************************
use File::Path;
use Fcntl qw(:DEFAULT :flock);
use Digest::MD5 qw(md5_base64);
use Storable;
use Data::Dumper;
use base "IDC";

sub StoreData{
my $self=shift;
my $args={
@_
};
die "Can't store - Data is clear" unless scalar %$args;
my $word;
for ('login','email','password'){$word.='#'.$args->{$_} }
my $file = Digest::MD5::md5_hex($word.'#'.$self->{secretWord});
mkdir $self->{StoreRequestDir} or die "Can't create freeze-dir!\n" unless -d $self->{StoreRequestDir} ;
store $args, $self->{StoreRequestDir}."/$file" or die "Can't store data!\n";
$args->{ConfirmLink} = "$self->{'scriptPath'}/$self->{'SCRIPT'}?confirm=".$file;
my $message = "Please Confirm: $args->{ConfirmLink} \n\n";
if($self->{sendAsHtml}){
$message = $self->get_record($self->read_file($self->{templateDir}."/".$self->{msgAskCreateAccount}),$args);
}
$self->male($args->{email}, $self->{fromAdmin}, '',$message) if $args->{email};
return 1;
}
sub confirmAccount{
        my $self=shift;
        my $key=shift;
        return undef, {ERROR_MSG=>"Confirm link expired!"} unless -f $self->{StoreRequestDir}.'/'.$key;
        my $data = Storable::retrieve($self->{StoreRequestDir}.'/'.$key) or die "can't restore data";
        unlink $self->{StoreRequestDir}.'/'.$key;
        return $self->createNewAccount($data);
}
sub createNewAccount{
my $self=shift;
my $data=shift;
#check exists account
my $sth = $self->dbh->prepare("SELECT id FROM $self->{tblAccounts} WHERE login=?");
my $rv = $sth->execute($data->{login}) or die $self->dbh->errstr;
$sth->finish;
return  (undef, {ERROR_MSG=>"'$data->{login}' $self->{MESSAGES}->{username_exists}", FIELD=>'login'}) if $rv ne '0E0';
my $id = $self->createRecord( table=>$self->{tblAccounts}, data=>{
        login =>$data->{login},
        password =>$self->cryptPass($data->{password}),
        email =>$data->{email},
        home =>$data->{home},
        diskquota =>$data->{diskquota},
        protect =>$data->{protect},
        rights =>$data->{rights},
        disabled =>$data->{disabled},
        expired =>$data->{expired},
        limitdays =>$data->{limitdays},
        first =>$data->{first},
        last =>$data->{last},
        country =>$data->{country},
        zip =>$data->{zip},
        city =>$data->{city},
        state =>$data->{state},
        address =>$data->{address},
        phone =>$data->{phone},
        fax =>$data->{fax},
        company =>$data->{company},
        comments =>$data->{comments},
        additional1 =>$data->{additional1},
        additional2 =>$data->{additional2},
        additional3 =>$data->{additional3},
        additional4 =>$data->{additional4},
        additional5 =>$data->{additional5},
});
mkpath("$self->{'clientroot'}/$data->{home}", 0, 0755) unless -d "$self->{'clientroot'}/$data->{home}";
$self->userGroups(id=>$id,group=>$data->{group});
if($self->{sendConfirmAccount}){
my $hrRights=$self->AccountRights;
for (split ',', $data->{right}){ $_=$hrRights->{$_}; }
$data->{rightsHR} = $data->{right};
my $message = "Client Login: $data->{login}\nClient Password: $data->{password}\nDisk Quota: $data->{diskquota}MB.\nDisabled Files: $data->{disabled}\nRights:$data->{rightsHR} \n\n";
if($self->{sendAsHtml}){
$message = $self->get_record($self->read_file($self->{templateDir}."/".$self->{msgCreateAccount}),$data);
}
$self->male($data->{email}, $self->{fromAdmin}, '',$message) if $data->{email};
}
return $id, undef, $data;
}
sub deleteAccount{
my $self = shift;
my $id = shift;
return if $id == $self->currentUser->{id};
my $userInfo=$self->getUserInfo($id);
#$self->rmFolder($self->{'clientroot'}."/".$userInfo->{home});
#delete account
$self->deleteRecord(table=>$self->{tblAccounts}, field=>'id', value=>$id);
#delete user groups
$self->deleteRecord(table=>$self->{tblUserGroup}, field=>'userId', value=>$id);
}
sub enableAccount{
my $self = shift;
my $id = shift;
$self->updateRecord(
table=>$self->{tblAccounts},
id=>$id,
data=>{disabled=>undef}
);
if($self->{sendNewAccount}){
my $user = $self->getUserInfo($id);
my $message = $self->get_record($self->read_file($self->{templateDir}."/".$self->{tmpJoinActivated}),$user);
$self->male($user->{email},$self->{fromAdmin},'',$message);
}
}
sub enableFolder{
my $self = shift;
my $id = shift;
$self->updateRecord(
table=>$self->{tblFolders},
id=>$id,
data=>{disabled=>undef}
);
}
sub enableGroup{
my $self = shift;
my $id = shift;
$self->updateRecord(
table=>$self->{tblGroups},
id=>$id,
data=>{disabled=>undef}
);
}
sub deleteFolder{
my $self = shift;
my $id = shift;
my $info=$self->getRecord(table=>$self->{tblFolders}, id=>$id);
$self->deleteRecord(table=>$self->{tblFolders}, field=>'id', value=>$id);
$self->deleteRecord(table=>$self->{tblGroupFolder}, field=>'folderId', value=>$id);
$self->rmFolder($info->{'path'})
}
sub deleteRights{
my $self = shift;
my $id = shift;
$self->deleteRecord(table=>$self->{tblGroupFolder}, field=>'id', value=>$id);
}
sub getGroupList{
my $self = shift;
my $list = $self->getList(
table=>$self->{tblGroups},
sort=>'name',
);
return $list;
}
sub showList{
my $self = shift;
my $arg = {
table=>undef,
page=>undef,
sort=>undef,
desc=>undef,
template=>undef,
@_
};
my $tmp=$self->read_file("$self->{'templateDir'}/$arg->{template}");
$tmp=~s/<template>(.*)<\/template>/%%list%%/s;
my $listtmp = $1;
my $html;
my $list = [];
if ($arg->{table} eq $self->{tblAccounts}){
if ($self->{CGI}->{group}){
$list = $self->getJoinedList(
table=>$self->{tblAccounts},
alias=>$self->{tblUserGroup},
joinedOn=>'userId',
fieldId=>'groupId',
fieldValue=>$self->{CGI}->{group},
sort=>$self->{CGI}->{sort},
desc=>$self->{CGI}->{desc},
);
}
else{
$list = $self->getList(
table=>$arg->{table},
sort=>$self->{CGI}->{sort},
desc=>$self->{CGI}->{desc},
rowsPerPage=>$self->{UsersPerPage},
page=>$self->{CGI}->{page}
);
}
}
else{
$list = $self->getList(
table=>$arg->{table},
sort=>$self->{CGI}->{sort},
desc=>$self->{CGI}->{desc},
);
}
for (@$list){
$_->{disabled} ||='';
$_->{diskquota}.=' MB.' if $_->{diskquota};
$_->{diskquota} ||='&#8734';
$_->{disabled} = "<a href=\"$self->{'SCRIPT'}?action=". ($arg->{table}  eq $self->{tblGroups}? 'groups' : $arg->{table} eq $self->{tblFolders}? 'folders':'users')."&amp;enable=$_->{id}\"><b>$_->{disabled}</b></a>" if $_->{disabled};
$html.=$self->get_record($listtmp,$_);
}
return $self->get_record($tmp,{list=>$html,group=>$self->{CGI}->{group}, rdesc=>$arg->{desc}? 0:1 });
}
sub getUserInfo{
my $self = shift;
my $account = shift;
my $info=$self->getRecord(table=>$self->{tblAccounts}, id=>$account);
my @rights = split(',',$info->{rights});
for (@rights){$info->{"rights_".$_}='checked'}
$info->{disabled} = $self->{MESSAGES}->{accountdisabled} if $info->{disabled};
$info->{disabled_1} = 'checked' if $info->{disabled};
my $groups = $self->getJoinedList(
table=>$self->{tblGroups},
alias=>$self->{tblUserGroup},
joinedOn=>'groupId',
fieldId=>'userId',
fieldValue=>$info->{id},
sort=>'name',
);
my $grp={};
for (@$groups){
$info->{groups} .= "<a href=\"$self->{SCRIPT}?action=groupinfo&amp;id=$_->{id}\">$_->{name},</a> ";
$grp->{$_->{id}}=$_;
}
$info->{userGroups}=$grp;
return $info;
}
##shared foldes
sub createFolder{
my $self = shift;
my $data = $self->{CGI};
# check exists folder
if ($data->{path}!~m/^(\/|\w\:)/ ){
if ($self->{defaultSharedRoot}){
$data->{path}=$self->{defaultSharedRoot}.'/'.$data->{path};
}
else{$data->{path}='/'.$data->{path};}
}
return  (undef, {ERROR_MSG=>$self->{MESSAGES}->{enterdirectorypath}, FIELD=>'path'}) unless $data->{path};
return  (undef, {ERROR_MSG=>$self->{MESSAGES}->{enterdirectorypath}, FIELD=>'name'}) unless $data->{name};
if ($data->{id}){
#mkdir "$data->{path}" or return  (undef, {ERROR_MSG=>$self->{MESSAGES}->{check_path}, FIELD=>'path'}) unless -e "$data->{path}";
my $inf = $self->getFolderInfo($data->{id});
$inf->{path};
rename($inf->{path},$data->{path}) or return  (undef, {ERROR_MSG=>$self->{MESSAGES}->{enterdirectorypath}, FIELD=>'path'}) if $inf->{path} ne $data->{path};
$self->updateRecord(
table=>$self->{tblFolders},
id=>$data->{id},
data=>{
name => $data->{name},
path => $data->{path},
description => $data->{description},
disabled => $data->{disabled},
slimit => $data->{slimit}
}
);
if ($inf->{path},$data->{path}){
$self->moveNotes($inf->{path},$data->{path},1);
}
if ($inf->{description} ne $data->{description}){
my $noteInfo=$self->getNote($data->{path});
$self->saveNote(file=>$data->{path},note=>$data->{description},id=>$noteInfo->{id});
}
return $data->{id};
}
return  (undef, {ERROR_MSG=>"$self->{MESSAGES}->{dexists} $data->{path} !", FIELD=>'path'}) if -e "$data->{path}";
mkdir "$data->{path}" or return  (undef, {ERROR_MSG=>$self->{MESSAGES}->{check_path}, FIELD=>'path'});
my $id = $self->createRecord(
table=>$self->{tblFolders},
data=>{
name => $data->{name},
path => $data->{path},
description => $data->{description},
disabled => $data->{disabled},
slimit => $data->{slimit}
}
);
$self->saveNote(file=>$data->{path},note=>$data->{description});
return $id;
}
sub createGroup{
my $self = shift;
my $data = $self->{CGI};
return  (undef, {ERROR_MSG=>$self->{MESSAGES}->{entergname}, FIELD=>'name'}) unless $data->{name};
if ($data->{id}){
$self->updateRecord(
table=>$self->{tblGroups},
id=>$data->{id},
data=>{
name => $data->{name},
groupemail => $data->{groupemail},
description => $data->{description},
disabled => $data->{disabled},
}
);
return $data->{id};
}
#check exists account
my $sth = $self->dbh->prepare("SELECT id FROM $self->{tblGroups} WHERE name=?");
my $rv = $sth->execute($data->{name}) or die $self->dbh->errstr;
$sth->finish;
return  (undef, {ERROR_MSG=>"$self->{MESSAGES}->{gexists}!", FIELD=>'name'}) if $rv ne '0E0';
my $id = $self->createRecord(
table=>$self->{tblGroups},
data=>{
name => $data->{name},
groupemail => $data->{groupemail},
description => $data->{description},
disabled => $data->{disabled},
}
);
return $id;
}
sub deleteGroup{
my $self = shift;
my $id = shift;
#delete account
$self->deleteRecord(table=>$self->{tblGroups}, field=>'id', value=>$id);
#delete user groups
$self->deleteRecord(table=>$self->{tblUserGroup}, field=>'groupId', value=>$id);
#delete group folders
$self->deleteRecord(table=>$self->{tblGroupFolder}, field=>'groupId', value=>$id);
}
sub getGroupInfo{
my $self = shift;
my $id = shift;
my $info=$self->getRecord(table=>$self->{tblGroups}, id=>$id);
$info->{"disabled_".$info->{disabled}}='checked';
$info->{disabledMsg} = '<div>Group Disabled</div>' if $info->{disabled};
my $folders = $self->getJoinedList(
table=>$self->{tblFolders},
alias=>$self->{tblGroupFolder},
joinedOn=>'folderId',
fieldId=>'groupId',
fieldValue=>$id,
sort=>'name',
);
$info->{folderList} = $folders;
for (@$folders){
$info->{folders} .= "<a href=\"$self->{SCRIPT}?action=groupFolder&amp;groupId=$id&folder=$_->{id}\">$_->{name},</a> ";
}
my $users = $self->getJoinedList(
table=>$self->{tblAccounts},
alias=>$self->{tblUserGroup},
joinedOn=>'userId',
fieldId=>'groupId',
fieldValue=>$id,
sort=>'login',
);
for (@$users){
$info->{users} .= "<a href=\"$self->{SCRIPT}?action=info&amp;account=$_->{id}\">$_->{login},</a> ";
}
return $info;
}
sub getFolderInfo{
my $self = shift;
my $id = shift;
my $info=$self->getRecord(table=>$self->{tblFolders}, id=>$id);
$info->{disabledMsg} = '<div>Folder Disabled</div>' if $info->{disabled};
return $info;
}
sub getOpt{
my $self = shift;
my $table= shift;
my $name = shift || 'name';
my $selected = shift;
my $skip = shift;
my $list = $self->getList(
table=>$table,
sort=>'name',
);
my $opt;
my %sk;
if (ref $skip eq 'ARRAY'){
for (@$skip){$sk{$_}++}
}
for (@$list){
next if $sk{$_->{id}};
$opt.="<option value=\"$_->{id}\" ".($selected eq $_->{id}? 'selected':'').">$_->{$name}</option>\n"
}
return $opt;
}
sub createRights{
my $self = shift;
my $rid = shift;
my $data = $self->{CGI};
my @right;
if (ref $data->{rights} eq 'ARRAY'){
for my $elem (@{$data->{rights}}){
push @right, $elem;
}
}
else{push @right, $data->{rights};}
if ($rid){
$self->updateRecord(
table=>$self->{tblGroupFolder},
id=>$rid,
data=>{
groupId => $data->{groupId},
folderId => $data->{folderId},
rights => join (',', @right),
useCustomProtect => $data->{useCustomProtect},
protect => $data->{protect},
description => $data->{description}
}
);
return $rid;
}
my $id = $self->createRecord(
table=>$self->{tblGroupFolder},
data=>{
groupId => $data->{groupId},
folderId => $data->{folderId},
rights => join (',', @right),
useCustomProtect => $data->{useCustomProtect},
protect => $data->{protect},
description => $data->{description}
}
);
return $id;
}
sub getFolderRights{
my $self=shift;
my $group = shift;
my $folder=shift;
my $sth=$self->dbh->prepare("SELECT * FROM  $self->{tblGroupFolder} WHERE groupId=? and folderId=?");
$sth->execute($group,$folder) or die $self->dbh->errstr;
my $info = $sth->fetchrow_hashref;
my @rights = split(',',$info->{rights});
for (@rights){$info->{"rights_".$_}='checked'}
$info->{"useCustomProtect_1"}='checked' if $info->{"useCustomProtect"};
return $info;
}
sub parseData{
my $self = shift;
my $data = shift;
my $parsed = {};
my @data_fields=split('\|', shift @$data);
die "uncorrect data" unless @data_fields;
$data_fields[@data_fields-1]=~s/\r|\n//g;
for(@$data){
$_=~s/\r|\n//g;
my @line=split('\|', $_);
for (0..@data_fields-1){
$parsed->{$line[0]}->{$data_fields[$_]}=$line[$_];
}
}
return $parsed,\@data_fields;
}
sub createAccount{
my $self = shift;
my $createByUser = shift;
my $data = $self->{CGI};
$data->{expired}=$self->formatDate($data->{expired}, 1) if $data->{expired};
if ($self->{autoExpireAfter} && !$data->{expired}){
my ($dd,$mm,$yy) = (localtime(time()+$self->{autoExpireAfter}*24*60*60))[3,4,5];
$data->{expired}= sprintf("%04D-%02D-%02D", $yy+1900,$mm+1,$dd);
}
return $self->updateAccount() if $data->{id};
return  (undef, {ERROR_MSG=>"'$data->{login}' $self->{MESSAGES}->{username_invalid}", FIELD=>'login'}) if $data->{login}!~/^[\d\w-_+]+$/;
#check exists account
 my $sth = $self->dbh->prepare("SELECT id FROM $self->{tblAccounts} WHERE login=?");
my $rv = $sth->execute($data->{login}) or die $self->dbh->errstr;
$sth->finish;
return  (undef, {ERROR_MSG=>"'$data->{login}' $self->{MESSAGES}->{username_exists}", FIELD=>'login'}) if $rv ne '0E0';
#check password
return  (undef, {ERROR_MSG=>$self->{MESSAGES}->{pass_incorrect}, FIELD=>'password'}) if !$data->{password} || $data->{password} ne $data->{password2};
my @right;
if (ref $data->{rights} eq 'ARRAY'){
for my $elem (@{$data->{rights}}){
push @right, $elem;
}
}
else{push @right, $data->{rights};}
my $store =         {
login => $data->{login},
password => $data->{password},
email => $data->{email},
home => $data->{userDir},
diskquota => $data->{diskquota} || 0,
protect => $data->{protect},
rights => join(',',@right),
disabled => $data->{disabled},
expired => $data->{expired},
first => $data->{first},
last => $data->{last},
country => $data->{country},
zip => $data->{zip},
city => $data->{city},
state => $data->{state},
address => $data->{address},
phone => $data->{phone},
fax => $data->{fax},
company => $data->{company},
comments => $data->{comments},
additional1 => $data->{additional1},
additional2 => $data->{additional2},
additional3 => $data->{additional3},
additional4 => $data->{additional4},
additional5 => $data->{additional5},
limitdays => $data->{limitdays},
};
my $id;
if ($createByUser){return $self->StoreData(%$store); }
else{
        $store->{password} = $self->cryptPass($store->{password});
        $id = $self->createRecord( table=>$self->{tblAccounts}, data=>$store);
        if ($id){mkpath("$self->{'clientroot'}/$data->{userDir}", 0, 0755) unless -d "$self->{'clientroot'}/$data->{userDir}";}
}
$self->userGroups(id=>$id,group=>$data->{group});
if($self->{sendConfirmAccount}){
my $hrRights=$self->AccountRights;
for (@right){ $_=$hrRights->{$_}; }
$data->{rightsHR} = join(', ',@right);
my $message = "Client Login: $data->{login}\nClient Password: $data->{password}\nDisk Quota: $data->{diskquota}MB.\nDisabled Files: $data->{disabled}\nRights:$data->{rightsHR} \n\n";
if($self->{sendAsHtml}){
$message = $self->get_record($self->read_file($self->{templateDir}."/".$self->{msgCreateAccount}),$data);
}
$self->male($data->{email}, $self->{fromAdmin}, '',$message) if $data->{email};
}
return $id;
}



sub AccountRights{
my $self=shift;
return {
u => $self->{MESSAGES}->{upload},
m => $self->{MESSAGES}->{move},
o=>$self->{MESSAGES}->{copy},
r => $self->{MESSAGES}->{download},
v=>$self->{MESSAGES}->{preview},
t=>$self->{MESSAGES}->{hotlink},
a => $self->{MESSAGES}->{rename},
p => $self->{MESSAGES}->{pack},
k=>$self->{MESSAGES}->{unpack},
z=>$self->{MESSAGES}->{zip},
w => $self->{MESSAGES}->{editor},
c => $self->{MESSAGES}->{chmod},
n => $self->{MESSAGES}->{mkdir},
l => $self->{MESSAGES}->{notes},
d => $self->{MESSAGES}->{delete}
};
}
sub updateAccount{
my $self = shift;
my $data = $self->{CGI};
#check password
#return  (undef, {ERROR_MSG=>"Your password is incorrect", FIELD=>'password'}) if !$data->{password} || $data->{password} ne $data->{password2};
#create home dir
#return  (undef, {ERROR_MSG=>"Account home directory $self->{'clientroot'}/$data->{login} already exists!", FIELD=>'login'}) if -e "$self->{'clientroot'}/$data->{login}";
mkpath("$self->{'clientroot'}/$data->{userDir}", 0, 0755) unless -d "$self->{'clientroot'}/$data->{userDir}";
my @right;
if (ref $data->{rights} eq 'ARRAY'){
for my $elem (@{$data->{rights}}){
push @right, $elem;
}
}
else{push @right, $data->{rights};}
my $d={
#login => $data->{login},
email => $data->{email},
home => $data->{userDir},
diskquota => $data->{diskquota}  || undef,
protect => $data->{protect},
rights => join(',',@right),
disabled => $data->{disabled},
expired => $data->{expired} || undef,
first => $data->{first},
last => $data->{last},
country => $data->{country},
zip => $data->{zip},
city => $data->{city},
state => $data->{state},
address => $data->{address},
phone => $data->{phone},
fax => $data->{fax},
company => $data->{company},
comments => $data->{comments},
additional1 => $data->{additional1},
additional2 => $data->{additional2},
additional3 => $data->{additional3},
additional4 => $data->{additional4},
additional5 => $data->{additional5},
limitdays => $data->{limitdays},
};
$d->{password} = $self->cryptPass($data->{password}) if $data->{password};
$self->updateRecord(
table=>$self->{tblAccounts},
id=>$data->{id},
data=>$d
);
$self->userGroups(id=>$data->{id},group=>$data->{group});
return $data->{id};
}
sub userGroups{
my $self = shift;
my $args = {@_};
my @groups;
if (ref $args->{group} eq 'ARRAY'){
for my $elem (@{$args->{group}}){
push @groups, $elem;
}
}
else{push @groups, $args->{group};}
$self->dbh->do("DELETE FROM $self->{tblUserGroup} WHERE userId=". $self->dbh->quote($args->{id})) or die $self->dbh->errstr;
my $sth=$self->dbh->prepare("INSERT INTO $self->{tblUserGroup} (userId,groupId) VALUES(?,?)");
for (@groups){
next unless $_;
$sth->execute($args->{id},$_) or die $self->dbh->errstr;
}
}
sub create{
my $self = shift;
my $data = shift;
die "login not set!" unless $data->{login};
open(F, "+<$self->{'userdata'}") || die("$self->{MESSAGES}->{cant_open_database} $self->{'userdata'} !");
flock(F, LOCK_EX);
my @data = <F>;
my ($list,$fields) = $self->parseData(\@data);
#check exists account
my $maxID;
for (keys %$list){
if ($data->{login} eq $list->{$_}->{login}){
close F;
$self->male(
$self->{adminMail},
$self->{adminMail},
"",
$self->get_record( $self->read_file($self->{templateDir}."/".$self->{templates}->{emlApplFailed}) ,$data)
);
return 0;
#$self->error(exit=>1, admin_send=>1, message=>"Login: $data->{login} already in use!", data=>$data);
#emlApplFailed
}
$maxID=$_ if $maxID < $_;
}
$data->{id} = ++$maxID;
#create folder
$data->{home} ||= $self->generateName();
while (-e "$self->{'clientroot'}/$data->{home}"){$data->{home}=$self->generateName();}
mkdir "$self->{'clientroot'}/$data->{home}";
$data->{password}= $self->cryptPass($data->{password});
#expired
$data->{expired} = $self->add_month("now",$data->{expired});
my @lct =(localtime($data->{expired}))[5,4,3];
$data->{expirationDate} = sprintf("%04D-%02D-%2D" ,$lct[0]+1900,$lct[1]+1,$lct[2]);
for (keys %$data){
$data->{$_}=~s/\n|\r/ /g;
$data->{$_}=~s/\|/I/g;
}
my $val=[];
for (@$fields){push @$val, $data->{$_}};
seek(F,tell F,0);
print F join ('|', @$val) . "\n";
close F;
# message to admin
if($self->{adminMail}){
$self->male(
$self->{adminMail},
$self->{adminMail},
"",
$self->get_record( $self->read_file($self->{templateDir}."/".$self->{templates}->{emlAdminConfirmation}) ,$data)
);
}
# message to customer
if($self->{autoResponderOn} && $data->{email}){
$self->male($data->{email},
$self->{replyMail},
"",
$self->get_record($self->read_file($self->{templateDir}."/".$self->{templates}->{emlConfirmation}),$data));
}
return 1;
}
sub add_month{
my $self= shift;
my $date= shift;
my $dif = int(shift);
#TODO - calculate by month,
return time+60*60*24*31*$dif;
}
sub error{
my $self = shift;
my $args={
exit => undef,
admin_send => undef,
message => undef,
data => undef,
@_
};
if ($args->{admin_send} && $self->{adminMail}){
my $tmp="";
for (sort{$a cmp $b} keys %{$args->{data}}){
$tmp.= "$_: $args->{data}->{$_}\n";
}
$self->male($self->{adminMail},
$self->{adminMail},
"Application failed ",
$args->{message}."\n\n".$tmp
);
}
print "$args->{message}";
exit if $args->{exit};
}
sub generateName{
my $self = shift;
my $length = shift||6;
$length = 6 if $length > 60;
my $string = "qwertzuiopasdfghjklyxcvbnmQWERTZUIOPASDFGHJKLYXCVBNM";
my @chars=split(//,$string);
my $name = "";
for (0..$length){
$name .= $chars[int(rand(@chars-1))];
}
return $name;
}
1;
