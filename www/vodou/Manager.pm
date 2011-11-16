package Manager;
#use lib './';
#************************************************************************************
#Build 1011A0001
#************************************************************************************
use Fcntl qw(:DEFAULT :flock);
use Data::Dumper;
use base "IDC";
use Archive::Tar;
use Compress::Zlib;
use Cwd;
use File::Copy;
use File::Path;
use File::Find;
use Archive::Zip;
use HTML::Entities;
use Encode;
our $fileType = {
html  => 'html.gif',
htm   => 'html.gif',
shtml => 'html.gif',
doc   => 'doc.gif',
rtf   => 'doc.gif',
exe   => 'exe.gif',
pdf   => 'pdf.gif',
bmp   => 'bmp.gif',
swf   => 'swf.gif',
gif   => 'gif.gif',
jpeg  => 'gif.gif',
jpg   => 'gif.gif',
jpe   => 'gif.gif',
png   => 'gif.gif',
txt   => 'txt.gif',
csv   => 'txt.gif',
ion   => 'ion.gif',
xls   => 'excel.gif',
csv   => 'excel.gif',
mp3   => 'music.gif',
wmv   => 'music.gif',
wma   => 'music.gif',
mpeg  => 'music.gif',
mpg   => 'music.gif',
wav   => 'music.gif',
mov  => 'music.gif',
tif   => 'tif.gif',
tiff   => 'tif.gif',
zip   => 'compress.gif',
gz        => 'gz.gif',
};
our @autoTextMode=('txt','pl','pm','html', 'htm','shtml','php','php4','js','css');
our $contentType = {
acgi=>'text/html',
htm=>'text/html',
html=>'text/html',
htmls=>'text/html',
htx=>'text/html',
shtml=>'text/html',
bmp=>'image/bmp',
jpe=>'image/jpeg',
jfif=>'image/jpeg',
'jfif-tbnl'=>'image/jpeg',
jpeg=>'image/jpeg',
jpg=>'image/jpeg',
gif=>'image/gif',
tif=>'image/tiff',
tiff=>'image/tiff',
png=>'image/png',
ico=>'image/x-icon',
ief=>'image/ief',
iefs=>'image/ief',
pbm=>'image/x-portable-bitmap',
pgm=>'image/x-portable-graymap',
pict=>'image/pict',
pic=>'image/pict',
ras=>'image/cmu-raster',
rast=>'image/cmu-raster',
dwg=>'image/pict',
dxf=>'image/pict',
aif=>'audio/x-aiff',
aifc=>'audio/x-aiff',
aiff=>'audio/x-aiff',
m2a=>'audio/mpeg',
mp2=>'audio/mpeg',
mpa=>'audio/mpeg',
wmv=>'audio/mpeg',
mpg=>'audio/mpeg',
mpga=>'audio/mpeg',
mp3=>'audio/mpeg',
kar=>'audio/midi',
mid=>'audio/midi',
midi=>'audio/midi',
wav=>'audio/x-wav',
ra=>'audio/x-pn-realaudio',
ram=>'audio/x-pn-realaudio',
rm=>'audio/x-pn-realaudio',
rmm=>'audio/x-pn-realaudio',
rmp=>'audio/x-pn-realaudio',
au=>'audio/basic',
avi=>'video/x-msvideo',
moov=>'video/quicktime',
mov=>'video/quicktime',
m1v=>'video/mpeg',
m2v=>'video/mpeg',
mp2=>'video/mpeg',
mpe=>'video/mpeg',
mpeg=>'video/mpeg',
mpg=>'video/mpeg',
mpa=>'video/mpeg',
css=>'text/css',
rtf=>'application/x-rtf',
rtx=>'application/x-rtf',
pot=>'attachment',
ppa=>'attachment',
pps=>'attachment',
ppt=>'attachment',
pptx=>'attachment',
pwz=>'attachment',
zip=>'attachment',
doc=>'application/msword',
docx=>'application/msword',
dot=>'application/msword',
w6w=>'application/msword',
wiz=>'application/msword',
word=>'application/msword',
wpd=>'application/wordperfect',
wp=>'application/wordperfect',
pdf=>'application/pdf',
xls=>'application/vnd.ms-excel',
xlsx=>'application/vnd.ms-excel',
xlc=>'application/vnd.ms-excel',
xll=>'application/vnd.ms-excel',
xlm=>'application/vnd.ms-excel',
xlb=>'application/vnd.ms-excel',
xlw=>'application/vnd.ms-excel',
ai=>'application/postscript',
eps=>'application/postscript',
ps=>'application/postscript',
exe=>'attachment',
class=>'application/x-java-class',
swf=>'application/x-shockwave-flash',
xml=>'application/xml',
tgz=>'application/x-compressed',
tar=>'application/x-tar',
wmf=>'windows/metafile',
help=>'application/x-helpfile',
gz=>'application/x-gzip',
};
sub getFileList{
my $self=shift;
my $dir=shift || $self->{CGI}->{dir};
my $path = $self->{'clientroot'};
my $stat = {};
my $dstat = {};
if($self->{CGI}->{gzfile}){
my $file=$self->getCurrentFile($dir."/".$self->{CGI}->{gzfile});
my $tar = Archive::Tar->new($file,1);
my @files = $tar->list_files();
my $i=0;
for(@files){
my @time = localtime $tar->{'_data'}->[$i]->{mtime};
my $ftime = sprintf ("%02d/%02d/%04d %02d:%02d:%02d" ,$time[3],$time[4]+1,$time[5]+1900,$time[2],$time[1],$time[0] );
if ($tar->{'_data'}->[$i]->{typeflag}==5){
$dstat->{$tar->{'_data'}->[$i]->{name}}->{mode}= sprintf("%04o",$tar->{'_data'}->[$i]->{mode} & 0777);
$dstat->{$tar->{'_data'}->[$i]->{name}}->{date}= $tar->{'_data'}->[$i]->{mtime};
$dstat->{$tar->{'_data'}->[$i]->{name}}->{name} = lc $tar->{'_data'}->[$i]->{name};
$dstat->{$tar->{'_data'}->[$i]->{name}}->{date}=$ftime;
$dstat->{$tar->{'_data'}->[$i]->{name}}->{_date}=$tar->{'_data'}->[$i]->{mtime};
}
else{
$stat->{$tar->{'_data'}->[$i]->{name}}->{mode}= sprintf("%04o",$tar->{'_data'}->[$i]->{mode} & 0777);
$stat->{$tar->{'_data'}->[$i]->{name}}->{date}= $tar->{'_data'}->[$i]->{mtime};
$stat->{$tar->{'_data'}->[$i]->{name}}->{name} = lc $tar->{'_data'}->[$i]->{name};
$stat->{$tar->{'_data'}->[$i]->{name}}->{size}= $tar->{'_data'}->[$i]->{size};
$tar->{'_data'}->[$i]->{name}=~m/\.([^\.\\\/]+)\Z/;
$stat->{$tar->{'_data'}->[$i]->{name}}->{ext} = $1;
$stat->{$tar->{'_data'}->[$i]->{name}}->{size}=~s/(\d)(\d{3})\Z/$1,$2/;
$stat->{$tar->{'_data'}->[$i]->{name}}->{date}=$ftime;
$stat->{$tar->{'_data'}->[$i]->{name}}->{_date}=$tar->{'_data'}->[$i]->{mtime};
}
$i++;
}
}
elsif($self->{CGI}->{search} && $self->{CGI}->{inNotes}){
$self->{CGI}->{dir}="";
my @files = $self->findNotes($self->{CGI}->{search}, $self->{CGI}->{matchCase});
for my $path (@files){
my ($ufile, $shared) = $self->_accessToFile($path);
if (-d $path){
$dstat->{$ufile}=$self->_setStat("$path",$ufile,1);
$dstat->{$ufile}->{shared} = 1 if $shared;
}
elsif(-f $path){
$ufile="(shared)".$ufile if $shared;
$stat->{$ufile}=$self->_setStat("$path",$ufile);
}
}
}
elsif($self->{CGI}->{search}){
my @files;
File::Find::find(sub { push @files, "$File::Find::dir/$_" if -e $_}, $self->getCurrentPath() ) if -d $self->getCurrentPath();
my $home = $self->getCurrentPath;
for (@files){
(my $file=$_)=~s/^$home//;
(my $filename=$file)=~s/\/$//;
$filename=~s/^.*\///;
$file=~s/^\///;
if($self->{CGI}->{search}=~m/\*/){
if($self->{CGI}->{search}=~m/(.*)\.(.*)/){
if($self->{CGI}->{matchCase}){
if($1 ne '*') {next if $filename!~m/$1\./;}
elsif($2 ne '*') {next if $filename!~m/\.$2/;}
}
else{
if($1 ne '*') {next if $filename!~m/$1\./i;}
elsif($2 ne '*') {next if $filename!~m/\.$2/i;}
}
}
}
else{
if($self->{CGI}->{matchCase}){next if $filename!~m/$self->{CGI}->{search}/;}
else{next if $filename!~m/$self->{CGI}->{search}/i;}
}
if (-d "$_"){$dstat->{$file}=$self->_setStat($_,$file,1);}
else{$stat->{$file}=$self->_setStat($_,$file);        }
}
unless ($self->{CGI}->{dir}){
@files=();
for my $shared (keys %{$self->{currentUser}->{'SHARED'}}){
next unless -d $self->{currentUser}->{'SHARED'}->{$shared}->{path};
File::Find::find(sub { push @files, "$File::Find::dir/$_" if -e $_}, $self->{currentUser}->{'SHARED'}->{$shared}->{path} );
my $home = $self->{currentUser}->{'SHARED'}->{$shared}->{path};
for (@files){
(my $file=$_)=~s/^$home//;
(my $filename=$file)=~s/\/$//;
$filename=~s/^.*\///;
$file=~s/^\///;
$file="$shared/".$file;
if($self->{CGI}->{search}=~m/\*/){
if($self->{CGI}->{search}=~m/(.*)\.(.*)/){
if($self->{CGI}->{matchCase}){
if($1 ne '*') {next if $filename!~m/$1\./;}
elsif($2 ne '*') {next if $filename!~m/\.$2/;}
}
else{
if($1 ne '*') {next if $filename!~m/$1\./i;}
elsif($2 ne '*') {next if $filename!~m/\.$2/i;}
}
}
}
else{
if($self->{CGI}->{matchCase}){next if $filename!~m/$self->{CGI}->{search}/;}
else{next if $filename!~m/$self->{CGI}->{search}/i;}
}
if (-d "$_"){
$dstat->{$file}=$self->_setStat($_,$file,1);
$dstat->{$file}->{shared} = 1 if $shared;
}
else{$stat->{"(shared)".$file}=$self->_setStat($_,"(shared)".$file);        }
}
}
}
}
else{
if (!$dir && $self->{currentUser}){
for my $shared (keys %{$self->{currentUser}->{'SHARED'}}){
next unless -d $self->{currentUser}->{'SHARED'}->{$shared}->{path};
$dstat->{$shared}=$self->_setStat($self->{currentUser}->{'SHARED'}->{$shared}->{path},$shared,1);
$dstat->{$shared}->{shared}= 1;
}
}
if ($dir =~ s/^\(shared\)//){
$dir =~ s/^([^\/]+)//;
if ($self->{currentUser}->{'SHARED'}->{$1}){
$path = $self->{currentUser}->{'SHARED'}->{$1}->{path};
$self->{isShared} = $1;
}
else{
$path=$self->{clientroot};
}
}
die $self->{MESSAGES}->{clientferror} unless $path;
$path.="/$dir";
opendir(DIR, $path) or die ($self->{MESSAGES}->{err_open_dir}. $path);
while(defined(my $file = readdir DIR)){
next if $file eq '..' or $file eq '.';
my @sb=stat("$path/$file");
my @time = localtime $sb[10];
if (-d "$path/$file"){$dstat->{$file}=$self->_setStat("$path/$file",$file,1);}
else{$stat->{$file}=$self->_setStat("$path/$file",$file);        }
}
close DIR;
}
for(keys %$stat){delete $stat->{$_} if $self->{hiddenFiles}->{$stat->{$_}->{'ext'}};}
return $dstat,$stat;
}
sub _setStat{
my $self=shift;
my $path=shift;
my $file=shift;
my $dir=shift;
my @sb=stat($path);
my @time = localtime $sb[10];
my $st = {};
if (! $dir){
$file=~m/\.([^\.]+)\Z/;
#next if !$myAdmin && $notShowFiles{lc $1};
$st->{ext} = $1;
($st->{size}= $sb[7])=~s/(\d)(\d{3})\Z/$1,$2/;
}
$st->{mode}= sprintf("%04o",$sb[2] & 0777);
$st->{_date}= $sb[10];
$st->{name} = lc $file;
if($self->{dateFormat} eq 'US'){$st->{date}= sprintf ("%02d/%02d/%04d %02d:%02d:%02d" ,$time[4]+1,$time[3],$time[5]+1900,$time[2],$time[1],$time[0] );}
elsif($self->{dateFormat} eq 'EU'){$st->{date}= sprintf ("%02d/%02d/%04d %02d:%02d:%02d" ,$time[3],$time[4]+1,$time[5]+1900,$time[2],$time[1],$time[0] );}
else{$st->{date}= sprintf ("%04d/%02d/%02d %02d:%02d:%02d" ,$time[5]+1900,$time[4]+1,$time[3],$time[2],$time[1],$time[0] );}
return $st;
}
sub _eqFile{
my $self = shift;
(my $file = shift)=~s/\/+/\//g;
(my $file2 = shift)=~s/\/+/\//g;
$file =~s/\/$//;
$file2 =~s/\/$//;

return 1 if $file eq $file2;
return 0;
}
sub getCurrentHome{
my $self = shift;
if ($self->{CGI}->{dir} =~ m/^\(shared\)([^\/]+)/){
return $self->{currentUser}->{'SHARED'}->{$1}->{path};
}
return $self->{'clientroot'};
}
sub getUserPath{
my $self = shift;
my $dir = shift || $self->{CGI}->{dir};
if ($dir =~ m/^\(shared\)([^\/]+)/){
return $self->{currentUser}->{'SHARED'}->{$1}->{path};
}
else{$dir=~s/$self->{'clientroot'}\/?//}
return "/$dir";
}
sub getCurrentPath{
my $self = shift;
my $dir = shift || $self->{CGI}->{dir};
my $right = shift;
$dir=~s/\.\.\/?//g;
my $path = $self->{'clientroot'};
if ($dir =~ s/^\(shared\)//){
$dir =~ s/^([^\/]+)//;
$self->{isShared} = $1;
$path = $self->{currentUser}->{'SHARED'}->{$1}->{path};
$self->{currentUser}->{currentShared}=$self->{currentUser}->{'SHARED'}->{$1};
}
if ($right && !$self->currentRights->{$right}){$self->errorRights($right)}
($path.="/".$dir) =~s/\/\/+/\//g;
return $path;
}

sub getAdminPath{
my $self = shift;
my $dir = shift || $self->{CGI}->{dir};
$dir=~s/\.\.\/?//g;
my $path;
if ($dir !~ s/^\(shared\)//){
$path= '/'.$self->{currentUser}->{'home'} if !$self->{currentUser}->{'isAdmin'};
$path.="/";
}
$path.=$dir;
$path=~s/\/\/+/\//g;
return $path;
}
sub getCurrentFile{
        my $self = shift;
        my $file = shift;
        my $right = shift;
        my $check = shift;
        $file=~s/\.\.\/?//g;
                return undef if !$file; #|| $file=~m/^[\/\\\s]+$/;
        my $path = $self->{'clientroot'};
        if ($file =~ s/^\/?\(shared\)//){
                $file =~ s/^([^\/]+)//;
                $self->{isShared} = $1;
                                return undef if !$self->{isShared} || $self->{isShared}=~m/^[\/\\\s]+$/;
                $path = $self->{currentUser}->{'SHARED'}->{$self->{isShared}}->{path};
        }
        if ($check){
        $file=~m/\.([^\.]+)$/;
        return undef if $self->{disabledFileList}->{lc $1};
        return undef if $self->currentDisabled->{lc $1};
        }
        if ($right && !$self->currentRights->{$right}){$self->errorRights($right)}
        ($path.="/".$file) =~s/\/\/+/\//g;
        return $path;
}
sub allowFile{
my $self=shift;
my $file=shift;
$file=~m/\.([^\.]+)$/;
return undef if $self->currentDisabled->{lc $1} || $self->{disabledFileList}->{lc $1};
return 1;
}
sub subDirFile{
my $self=shift;
my $path=shift;
$path=~s/\/+$//;
my @parts=split('/', $path);
my $file=pop @parts;
(my $ext=$file)=~s/^.*\.//;
return (join ('/', @parts),$file,$ext);
}
sub currentRights{
        my $self=shift;
        return $self->{isShared} && !$self->currentUser->{isAdmin} ? $self->currentUser->{SHARED}->{$self->{isShared}}->{RIGHTS}:$self->currentUser->{RIGHTS};
}
sub currentDisabled{
my $self=shift;
my $disabled = $self->{isShared}? $self->currentUser->{SHARED}->{$self->{isShared}}->{PROTECT} || {} :$self->currentUser->{PROTECT} || {};
return {%{$self->{disabledFileList}},%$disabled};
}
sub errorRights{
my $self=shift;
my $type=shift;
$self->error('You do not have sufficient privileges to perform this operation');
}
sub asHtml{
my $self=shift;
my $args={
text=>undef,
title=>undef,
close=>undef,
@_
};
my $data={
CONTENT=>$args->{text},
TITLE=>$args->{title},
script => $self->{SCRIPT},
ONLOAD => $args->{ONLOAD}? $args->{ONLOAD} :$args->{close}? 'onload="go();"':'',
dir => $self->{CGI}->{dir},
htmlDataFolder => $self->{htmlDataFolder},
JSCRIPT =>$args->{JSCRIPT},
};
print "Content-Type: text/html; charset=utf-8\n\n";
print $self->tmpToHtml($self->{'tmpWndMain'},$data);
exit;
}
sub confirmByEmail{
my $self=shift;
my $args={@_};
$args->{data}->{user}=$self->currentUser->{login};
$args->{data}->{RegisteredOwner}=$self->{RegisteredOwner};
$self->male(
$args->{to},
$args->{from},
$args->{subject},
$self->tmpToHtml(delete $args->{template},$args->{data})
);
}
sub getQueryString{
my $self=shift;
my @vars;
for ('r','dir','opt','search'){
push @vars, "$_=$self->{CGI}->{$_}" if $self->{CGI}->{$_};
}
return join "&amp;", @vars;
}
sub logger{
my $self=shift;
my $message=shift;
return unless $self->{logActivityOn};
$self->log($self->{logActivity}, $message);
}
sub usedSpace{
        my $self=shift;
        (my $dir = shift || $self->{clientroot})=~s/(\s)/\\$1/g;
        if ($^O=~m/linux|unix|aix|freebsd|Solaris/){
        (my $size=`du -s $dir`)=~s/\D.*$//;
        return  $size;
        }
        return 0;
}
sub currentfreeSpace{
        my ($self, $space)=@_;
        my $quota = $self->{isShared}? $self->currentUser->{'SHARED'}->{$self->{isShared}}->{slimit}: $self->currentUser->{diskquota};
        return  1 unless $quota;
        my $used = $self->usedSpace($self->{isShared}? $self->currentUser->{'SHARED'}->{$self->{isShared}}->{path} : undef) + $space / 1024;
        return $used > 1024*$quota? 0:1;
}
sub saveFile{
my $self=shift;
my $file=shift;
my $path=shift;
my $mode = shift;
my %modeFiles;
unless ($mode){
for(@autoTextMode){$modeFiles{$_}++}
}
(my $filename = $file) =~s!^.*[/\\]!!;
$filename =~m!\.(\w*?)$!;
my $ext = $1;
$filename=~s/[\*\?\|\;;\{\}<>\@\#~\“]/_/g;
open(FILE,">$path/$filename") or die $!. " $path  - $filename";
binmode FILE if $mode==1 or (!$mode && !$modeFiles{$ext});
while (read($file, my $buffer,1024)) {
#hack for clear \r
$buffer=~s/\r//gs unless ($mode==1 || (!$mode && !$modeFiles{$ext}));
print FILE $buffer;
}
close(FILE);
return $filename;
}
sub Tree{
my $self = shift;
$self->{Tree}={} unless $self->{Tree};
return $self->{Tree};
}
sub _accessToFile{
my $self = shift;
my $file = shift;
my $user = $self->currentUser;
if($file=~s/^$self->{'clientroot'}//){ return $file,0};
for (keys %{$user->{SHARED}}){
next unless $user->{SHARED}->{$_}->{path};
if($file=~s/^$user->{SHARED}->{$_}->{path}\/?/$_\//){
return $file,1
};
}
return 0;
}
sub addNote{
my $self=shift;
(my $file=shift) =~s/\/+/\//g;
my $note = shift;
return unless $note;
$self->saveNote(file=>$file,note=>$note);
}
sub getNote{
my $self=shift;
my $file=shift;
my $flag = shift;
(my $path = $self->getCurrentFile($file))=~s/\/$//;
my $info = $self->SUPER::getNote($path);
return undef unless $info;
if ($flag){
$info->{note} = substr($info->{note},0,65);
$info->{note} =~s!<br>.*|\r|\n! !gsi;
}
return $info->{note};
}
sub getIcon{
my $self= shift;
my $ext = shift;
if (shift){
return "<img src=\"$self->{htmlDataFolder}/folder.gif\">" if -d $ext;
(my $f, my $p,$ext)=$self->subDirFile($ext);
}
my $icon = $Manager::fileType->{lc $ext} || 'file.gif';
return "<img src=\"$self->{htmlDataFolder}/$icon\" alt=\"\"></a>";
}
sub setHotLink{
my $self= shift;
my $file= shift;
my $limit=shift;
my $pwd  =shift;
my $path=$self->getCurrentFile($file, 't', 1);
$self->errorRights($self->{MESSAGES}->{hotlinkerror}) unless $path;
$limit = '#'.$limit if $limit;
$pwd = '#'.$pwd if $pwd;
my $md5 = Digest::MD5::md5_hex($file.$self->{hotLinkWord}.$self->currentUser->{id}.$limit.$pwd);
return ($file,$md5);
}
sub hotLink{
        my $self= shift;
        my $file = $self->{CGI}->{file};
        my $md5  = $self->{CGI}->{link};
        my $account =$self->{CGI}->{a};
        my $add = '#'.$self->{CGI}->{l} if $self->{CGI}->{l};
        $add .= '#'.$self->{CGI}->{pwd} if $self->{CGI}->{pwd};
        $self->getMessages( $self->{currentUser}->{language}  || 'en');
        if ($self->{CGI}->{l} && time()>$self->{CGI}->{l}){$self->error('This link expired!');}
        if ($md5 eq Digest::MD5::md5_hex($file.$self->{hotLinkWord}.$account.$add)){
        my $user = $self->getUserById($account);
        my $path=$self->getCurrentFile($file, 'r', 1);
        my ($fdir,$filename,$ext) = $self->subDirFile($file);
        if (-e $path){
                my $contentType=$self->getContentType($ext) || 'attachment';
        if($contentType){
        my $encodefilename = decode("utf8", $filename);
        if ($contentType eq 'attachment' || lc $ext eq 'pdf'){
                print "Content-type: multipart/octet-stream\n";
                print "Content-Disposition: attachment; filename=\"$encodefilename\"\n\n";
        }
        else{
                print "Content-Type: $contentType\n";
                print "Content-Disposition: inline; filename=\"$encodefilename\"\n\n";
        }
        open(F, "$path") or $self->error($self->{MESSAGES}->{err_open_file});
        binmode F;
        binmode STDOUT;
        while(<F>){print;}
        close F;
        }
        }
        else{print "Location: /404.html\n\n";}
        }
        elsif( defined $self->{CGI}->{pwd} || $self->{CGI}->{p} ){
        for ('file','link','l','a'){$self->{CGI}->{$_} = HTML::Entities::encode_entities($self->{CGI}->{$_})}
        my $text = "<div style=\"position:absolute;z-index:1;visibility:visible;left:36%;top:102px;width:390px;height:20px;\"><font face='Verdana' class='errorlogin'><B>&nbsp; $self->{MESSAGES}->{pass_incorrect}!</b></font></div>" if $self->{CGI}->{pwd};
        $text .= "<div style=\"position:absolute;z-index:1;visibility:visible;left:36%;top:50px;width:390px;height:133px;\"><table><tr><td><span style=\"filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$self->{htmlDataFolder}/Skins/$self->{SkinFolder}/$self->{HotlinkIcon},sizingMethod=image);display:block;height:$self->{IconHeight};width:$self->{IconWidth};background:url($self->{htmlDataFolder}/Skins/$self->{SkinFolder}/$self->{HotlinkIcon}) !important;background:none;\"></span></td><td class=\"subheader\">$self->{MESSAGES}->{hotlink}</td></tr></table><table><tr><td><hr width=\"390px\" class=\"line\"></td></tr><tr><td>&nbsp;$self->{MESSAGES}->{password}: <input type=\"password\" name=\"pwd\"> <input type=\"submit\" value=\"$self->{MESSAGES}->{ok}\"></tr></table><table width=\"100%\"><tr><td><hr width=\"390px\" class=\"line\"></td></tr></table>";
        $text .= "<input type=\"hidden\" name=\"file\" value=\"$self->{CGI}->{file}\">";
        $text .= "<input type=\"hidden\" name=\"link\" value=\"$self->{CGI}->{link}\">";
        $text .= "<input type=\"hidden\" name=\"l\" value=\"$self->{CGI}->{l}\">" if $self->{CGI}->{l};
        $text .= "<input type=\"hidden\" name=\"a\" value=\"$self->{CGI}->{a}\">";
        $self->asHtml(text=>$text, title=>"$self->{MESSAGES}->{hotlink}");
        }
        else{
        print "Location: /404.html\n\n";
        }
        exit;
}
sub getContentType{
my($self,$ext)=@_;
return $contentType->{lc $ext};
}
sub getFolderOwher{
        my $self = shift;
        my $dir = shift;
        $dir =~ m/^$self->{'clientroot'}\/?([^\/]+)/;
        return undef unless $1;
        return $self->getUser($1);
}
sub sendToFolderOwner{
        my $self= shift;
        my $dir = shift;
        my $message=shift;
        return unless $self->{currentUser}->{isAdmin};

        my $owner = $self->getFolderOwher($dir);
        return unless $owner;
        return if $owner->{email} eq $self->{toAdmin};
        $self->male($owner->{email}, $self->{fromAdmin}, "$self->{MESSAGES}->{re} $self->{currentUser}->{login} $self->{MESSAGES}->{successfully_uploaded}:", $message);
}
1;
