#!/usr/bin/perl
use strict;
#use lib './';
#************************************************************************************
#Build 1011A0001
#************************************************************************************
use CGI::Carp qw(fatalsToBrowser);
(our $script=$0) =~s!^.*[/\\]!!;
use Manager;
use Digest::MD5;
use Data::Dumper;
use CGI::Cookie;
use utf8;
use URI::Escape;
use Encode qw(encode);
use Encode;
#************************************************************************************
#Icon Artwork By Silvestre Herrera
#
#Check out his other icon artwork here: http://www.silvestre.com.ar
#
#Icons released under the terms of the GNU General Public License version 2 and/or 3
#
#************************************************************************************
my %SUB = (
download  => \&download,
upload=> \&upload2,
uploadfl  =>  \&uploadfl,
uploadja  => \&uploadja,
uploadok  => \&uploadok,
uplja => \&uplja,
userarea  => \&userarea,
findfile  => \&findfile,
about => \&about,
view  => \&view,
chmod => \&chmod_f,
logout=> \&logout,
delete=> \&delete,
mkdir => \&mkdir,
rename=> \&rename,
copy  => \&copy_f,
pack  => \&pack,
unpack=> \&unpack,
move  => \&move,
edit  => \&edit,
tree  => \&tree,
notes => \&notes,
batch_download => \&batch_download,
hotlink=> \&hotlink,
flu=> \&flu,
);
my $fm = new Manager(config=>'Configuration.pl', SCRIPT=>$script);
$fm->parseCGI;
my $dir=$fm->{CGI}->{dir};



about() if $fm->{CGI}->{action} eq 'about';
$fm->hotLink() if $fm->{CGI}->{file} && $fm->{CGI}->{link} && $fm->{CGI}->{a};
forgott() if $fm->{CGI}->{action} eq 'forgott';
restore() if $fm->{CGI}->{action} eq 'restore';
flu() if $fm->{CGI}->{action} eq 'flu';
uplja() if $fm->{CGI}->{action} eq 'uplja';
$SUB{upload} = \&upload if $fm->{uploadPrBarOn};
$SUB{upload} = \&uploadX if $fm->{xUploadOn};
my $sid = $fm->getCookie($fm->{cookieName});
$sid=~s/;$//;
if ($fm->{CGI}->{action} eq 'logout'){
$fm->currentUserBySid();
$fm->logger("Logged Out");
$fm->logout;
exit;
}
if($fm->{CGI}->{log_in}){
$fm->getMessages( $fm->{CGI}->{language} || $fm->{currentUser}->{language}  || 'en');
$fm->login(password=>$fm->{CGI}->{password},login=>$fm->{CGI}->{login});
$fm->logger("Logged In");
#clear all old sessions
$fm->clearSessions;
print "Location: $fm->{SCRIPT}\n\n";
}
elsif($sid){ print L "[sid] $sid\n";#close L;
$fm->currentUserBySid();
}
unless($fm->currentUser){$fm->login;}
my $user = $fm->currentUser();
$fm->logout(3) if $user->{disabled};
$fm->logout(3) unless $fm->validTime();
$fm->getMessages( $fm->{CGI}->{language} || $fm->{currentUser}->{language}  || 'en');
$fm->{CGI}->{opt} ||= 'name';
$SUB{$fm->{CGI}->{action}}->() if defined $SUB{$fm->{CGI}->{action}};
my ($dsort,$sort)=$fm->getFileList();
#my $Rights = ($fm->{isShared} && !$fm->currentUser->{isAdmin})? $user->{SHARED}->{$fm->{isShared}}->{RIGHTS}:$user->{RIGHTS};
my $Rights = ($fm->{isShared}  && !$fm->currentUser->{isAdmin})? $user->{SHARED}->{$fm->{isShared}}->{RIGHTS}:$user->{RIGHTS};
my %opt_;
my %arrow;
if($fm->{CGI}->{r}){$arrow{$fm->{CGI}->{opt}} = "<img src=\"$fm->{htmlDataFolder}/arrow_up.gif\" align=\"top\" alt=\"\">&nbsp;";}
else{
$arrow{$fm->{CGI}->{opt}} = "<img src=\"$fm->{htmlDataFolder}/arrow_down.gif\" align=\"top\" alt=\"\">&nbsp;";
$opt_{$fm->{CGI}->{opt}}="&amp;r=1";
}
my $overQuota = $fm->currentfreeSpace? undef:1;
print "Content-type: text/html; charset=utf-8\n\n";
print qq~
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<head>
<title>$fm->{Filemanagertitle}</title>
<link rel="stylesheet" type="text/css" href="$fm->{htmlDataFolder}/fm.css">
<link rel="shortcut icon" href="$fm->{htmlDataFolder}/favicon.ico">
<script src="$fm->{htmlDataFolder}/menu.js" type="text/javascript"></script>
<script src="$fm->{htmlDataFolder}/fm.js" type="text/javascript"></script>
<script src="$fm->{htmlDataFolder}/css_browser_selector.js" type="text/javascript"></script>
<script type="text/javascript">
var timerId;
var timeOut=$fm->{timeOut};
var script = "$fm->{SCRIPT}";
var overQuota = "$overQuota";
function init(){
res();
}
function res(){
if (window.innerHeight){
var h = window.innerHeight-282;
document.getElementById('tbContent').style.height= h<200? 200:h;
}
}
</script>
</head>
<body onload="init();" ~;
print qq~onMouseMove="ResetIdle()" onKeyPress="ResetIdle();"  onLoad=" ResetIdle();"~  if $fm->{timeOut};
print qq~>
<script type="text/javascript">
~.($user->{isAdmin}?"isAdmin=1;\n":"isAdmin=0;").qq~
var arrRights = new Array ();
var ClientScriptName = '$fm->{ClientScriptName}';
var FileManagerScriptName = '$fm->{FileManagerScriptName}';
var ControlPanel = '$fm->{MESSAGES}->{control_panel}';
var MyAccount = '$fm->{MESSAGES}->{accountinfo_title}';
var Exit = '$fm->{MESSAGES}->{exit}';
var Copy = '$fm->{MESSAGES}->{copy}';
var Rename = '$fm->{MESSAGES}->{rename}';
var Delete = '$fm->{MESSAGES}->{delete}';
var Move = '$fm->{MESSAGES}->{move}';
var Chmod = '$fm->{MESSAGES}->{chmod}';
var Search = '$fm->{MESSAGES}->{search}';
var SelectAll = '$fm->{MESSAGES}->{select_all}';
var Upload = '$fm->{MESSAGES}->{upload}';
var Download = '$fm->{MESSAGES}->{download}';
var Preview = '$fm->{MESSAGES}->{preview}';
var Pack = '$fm->{MESSAGES}->{pack}';
var Unpack = '$fm->{MESSAGES}->{unpack}';
var Editor = '$fm->{MESSAGES}->{editor}';
var ContactUs = '$fm->{MESSAGES}->{contact_us}';
var Tutorials = '$fm->{MESSAGES}->{tutorials}';
var SupportForums = '$fm->{MESSAGES}->{support_forums}';
var About = '$fm->{MESSAGES}->{about}';
var ContactUsLink = '$fm->{ContactUsLink}';
var select_file = '$fm->{MESSAGES}->{select_file}';
var only_one_file = '$fm->{MESSAGES}->{only_one_file}';
var no_selection = '$fm->{MESSAGES}->{no_selection}';
var confirm_delete = '$fm->{MESSAGES}->{confirm_delete}';
var enter_zipname = '$fm->{MESSAGES}->{enter_zipname}';
var over_quota = '$fm->{MESSAGES}->{over_quota}';
~;
for (keys %{$fm->currentRights}){print "arrRights['$_']=1\n";}
print qq~
fwLoadMenus();
</script>
~;
my $qs = "";
my $colspan = $fm->{fileDescriptionOn}?7:6;
(my $tdir=$dir)=~s/^\(shared\)//;
my @path = split('/',$tdir);
$tdir="";
my $i=0;
for (@path){
$tdir &&= $tdir.'/';
$tdir .= $_;
$_= "<a href='$script?dir=".($dir=~m/^\(shared\)/ ? '(shared)':'')."$tdir'>$_</a>";
}
$tdir = join ('/',@path);
print qq~
<table id="fmMain">
<tr><td>
<div id="head">
<a style="z-index:-1;position:absolute;left:0px;width:100%;height:132px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{TopBar}',sizingMethod=scale);"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{TopBar}" width="100%" height="132px" border="0" alt=""></a>
<a style="z-index:-1;position:absolute;top:110px;left:0px;width:100%;height:23px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{FilterBar}',sizingMethod=scale);"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{FilterBar}" width="100%" height="23px" border="0" alt=""></a>
<table cellpadding="0" style="position:absolute;left:3px;top:3px;">
<tr>
<td width=$fm->{MESSAGES}->{file_position}><a href="#" onmouseout="FW_startTimeout();"  onmouseover="window.FW_showMenu($fm->{MESSAGES}->{file_coordinates});" class="Menucss">$fm->{MESSAGES}->{file}</a>&nbsp;</td>
<td width=$fm->{MESSAGES}->{edit_position}><a href="#" onmouseout="FW_startTimeout();"  onmouseover="window.FW_showMenu($fm->{MESSAGES}->{edit_coordinates});" class="Menucss">$fm->{MESSAGES}->{edit}</a>&nbsp;</td>
<td width=$fm->{MESSAGES}->{tools_position}><a href="#" onmouseout="FW_startTimeout();"  onmouseover="window.FW_showMenu($fm->{MESSAGES}->{tools_coordinates});" class="Menucss">$fm->{MESSAGES}->{tools}</a>&nbsp;</td>
<td width=$fm->{MESSAGES}->{help_position}><a href="#" onmouseout="FW_startTimeout();"  onmouseover="window.FW_showMenu($fm->{MESSAGES}->{help_coordinates});" class="Menucss">$fm->{MESSAGES}->{help}</a>&nbsp;</td>
<td align=right class="misc_header">$fm->{MESSAGES}->{login_as}: <span class="logged_in_as">$user->{login}</span>
~.qbar().qq~
</td>
</tr>
</table>
<form name="mode" action="#">
<input type="hidden" name="dir" value="$fm->{CGI}->{dir}">
<input type="hidden" name="gzfile" value="$fm->{CGI}->{gzfile}">
<table style="position:absolute;left:3px;top:42px;">
<tr><td class="misc_header">$fm->{MESSAGES}->{search}: <input type=text name=search size=25 value="$fm->{CGI}->{search}">
<input type="submit" value='$fm->{MESSAGES}->{search}'>
<input type="checkbox" name="matchCase" value=1 ~. ($fm->{CGI}->{matchCase}? 'checked':'') .qq~> $fm->{MESSAGES}->{match_case}
<input type="checkbox" name="inNotes" value=1 ~. ($fm->{CGI}->{inNotes}? 'checked':'') .qq~> $fm->{MESSAGES}->{notes}
</td><td align="right" class="misc_header" style="visibility:$fm->{TransferModeDisplay};">$fm->{MESSAGES}->{transfer_mode}:
<select name="transfer" style="visibility:$fm->{TransferModeDisplay};">
<option  value="" ~. (!$fm->{CGI}->{transfer}? 'selected':'') .qq~>Auto [$fm->{autoTxtType}]</option>
<option  value="t"~. ($fm->{CGI}->{transfer} eq 't'? 'selected':'') .qq~>Text [plain text, html, etc.]</option>
<option  value="b"~. ($fm->{CGI}->{transfer} eq 'b'? 'selected':'') .qq~>Binary [archives, doc, etc.]</option>
</select></td></tr>
<tr><td>&nbsp;</td></tr>
<tr class="misc_header" ><td colspan=$colspan class=on><a href="$script?"><b>/</b></a><b>$tdir~.($tdir? '/':'').qq~*.*</b></td></tr>
</table>
</form>
</div>
</td></tr>
~;
my $disabled = 'disabled' if $fm->{CGI}->{gzfile};
my $col1 = $fm->{fileDescriptionOn}? '37%':'48%';
my $col2 = $fm->{fileDescriptionOn}? '6%':'10%';
my $col3 = $fm->{fileDescriptionOn}? '12%':'22%';
print qq~
<tr><td>
<form name="files" id="files" action="#">
<table width="99%" style="position:absolute;left:1px;top:107px;">
<tr class="noscroll">
<th align="center" width="2%" height="20">
<input type="checkbox" name="all_file" onclick="selectAll()" $disabled></th>
<th align="left" width="$col1">$arrow{name}<a href="$fm->{SCRIPT}?opt=name&amp;dir=$dir$opt_{name}$qs">$fm->{MESSAGES}->{name}</a></th>
<th align="left" width="$col2">$arrow{ext}<a href="$script?opt=ext&amp;dir=$dir$opt_{ext}$qs">$fm->{MESSAGES}->{ext}</a></th>
<th align="left" width="$col3">$arrow{size}<a href="$script?opt=size&amp;dir=$dir$opt_{size}$qs">$fm->{MESSAGES}->{size}</a></th>~;
print qq~<th align="left" width="34%"><a>$fm->{MESSAGES}{description}</a></th>~ if $fm->{fileDescriptionOn};
print qq~<th align="left" width="11%">$arrow{date}<a href="$script?opt=date&amp;dir=$dir$opt_{date}$qs">$fm->{MESSAGES}->{date}</a></th>
</tr>
</table>
~;
print qq~
<tr>
<td height="99%" width="100%" valign="top">
<div id="op8andup-hook-id" class="container">
 <table width="100%" class="scrollTable" id="tbContent">
<!--thead>
<tr class="noscroll">
<th width="2%" height="18">
<input type="checkbox" name="all_file" onclick="selectAll()" $disabled></th>
<th width="$col1">$arrow{name}<a href="$fm->{SCRIPT}?opt=name&amp;dir=$dir$opt_{name}$qs">$fm->{MESSAGES}->{name}</a></th>
<th width="$col2">$arrow{ext}<a href="$script?opt=ext&amp;dir=$dir$opt_{ext}$qs">$fm->{MESSAGES}->{ext}</a></th>
<th width="$col3">$arrow{size}<a href="$script?opt=size&amp;dir=$dir$opt_{size}$qs">$fm->{MESSAGES}->{size}</a></th>~;
print qq~<th width="34%">$fm->{MESSAGES}{description}</th>~ if $fm->{fileDescriptionOn};
print qq~<th width="12%">$arrow{date}<a href="$script?opt=date&amp;dir=$dir$opt_{date}$qs">$fm->{MESSAGES}->{date}</a></th>

</tr>
</thead-->
<tbody>
~;
my $addQs = "&opt=$fm->{opt}" if $fm->{opt};
$addQs .= "&opt_=$fm->{opt_}" if $fm->{opt_};
my (@skeys,@dkeys);
if($fm->{CGI}->{opt} eq 'ext' or $fm->{CGI}->{opt} eq 'name' or $fm->{CGI}->{opt} eq 'mode'){
@skeys = sort {lc $sort->{$a}->{$fm->{CGI}->{opt}} cmp lc $sort->{$b}->{$fm->{CGI}->{opt}} } keys %$sort;
@dkeys = sort {lc $dsort->{$a}->{$fm->{CGI}->{opt}}  cmp lc $dsort->{$b}->{$fm->{CGI}->{opt}} } keys %$dsort;
}
elsif($fm->{CGI}->{opt} eq 'date'){
@skeys = sort {$sort->{$b}->{_date} <=> $sort->{$a}->{_date}} keys %$sort;
@dkeys = sort {$dsort->{$b}->{_date} <=> $dsort->{$a}->{_date}} keys %$dsort;
}
elsif($fm->{CGI}->{opt} eq 'size'){
@skeys = sort {$sort->{$a}->{size} <=> $sort->{$b}->{size}} keys %$sort;
@dkeys = sort {lc $a cmp lc $b} keys %$dsort;
}
else{
@skeys = sort {$a <=> $b} keys %$sort;
@dkeys = sort {$a <=> $b} keys %$dsort;
}
@skeys = reverse @skeys if $fm->{CGI}->{r};
@dkeys = reverse @dkeys if $fm->{CGI}->{r} && ($fm->{CGI}->{opt} ne 'ext' and $fm->{CGI}->{opt} ne 'size');
if($fm->{CGI}->{search} && !(@dkeys || @skeys)){
print "<tr><th colspan=\"".($fm->{fileDescriptionOn}? 7:6)."\"><br><br><br><br><br><b>$fm->{MESSAGES}->{no_results}</b></th></tr>";
print "</td></tr></tbody></table><input type=\"hidden\" name=\"file\"><input type=\"hidden\" name=\"folder\"></div>";
print "</td></tr><tr><td>";
print footer();
exit;
}
(my $up=$dir)=~s![/\\][^/\\]*$!! if $dir=~m/[\/\\]/;
if ($dir or $fm->{CGI}->{gzfile} or $fm->{CGI}->{search}){
$up=$dir if $fm->{CGI}->{gzfile} or $fm->{CGI}->{search};
for(".."){
print qq~<tr class="off" onmouseover="sh(this)" onmouseout="shh(this)" height="20">
<td width="2%">&nbsp;</td>
<td width="$col1"><div><a href='$script?dir=$up$addQs'><img src="$fm->{htmlDataFolder}/up.gif" border="0"></a> <a href='$script?dir=$up$addQs'>[$_]</div></td>
<td width="$col2">&nbsp;</td>
<td width="$col3">&lt;$fm->{MESSAGES}->{DIR}&gt;</td>~;
print "<td width=\"33%\">&nbsp;</td>" if $fm->{fileDescriptionOn};
print "<td width=12%>$sort->{$_}->{date}</td>";
print "</tr>";
}
}
my $shDir =$dir;
$shDir &&="$dir/";
my $has_descr = {};
for(@dkeys){
#(my $tmpDir="$_")=~s/\&/%26/g;
#$tmpDir=~s/#/%23/g;
my $tmpDir=$_;
my $sh = "(shared)" if $dsort->{$_}->{shared};
print qq~<tr class=off onmouseover="sh(this)" onmouseout="shh(this)">\n<td  width="2%" height="20" align="center">~;
print qq~<input type=checkbox name=folder value="$sh$shDir$_" $disabled ~. (!$dir && $dsort->{$_}->{shared} ? 'disabled':'').qq~ >~;
print "</td><td  nowrap width=\"$col1\"><div>";
print "<a href=\"$fm->{SCRIPT}?dir=$sh$shDir$tmpDir$addQs\" >" unless $disabled;
print "<img src=\"$fm->{htmlDataFolder}/".($dsort->{$_}->{shared}? 's':'')."folder.gif\" alt=\"\">";
print "</a>" unless $disabled;
my $note = $fm->getNote("$sh$shDir$_", 1) if $fm->{fileDescriptionOn};
print "&nbsp;<a href=\"javascript:notesview('$sh$shDir$tmpDir')\"><img src=\"$fm->{htmlDataFolder}/note.gif\"></a>"  if $fm->{fileDescriptionOn} && $note;
(my $tmp=$_)=~s/^(.{65}).+/$1\.\.\./;
if ($disabled){print "[$tmp]";}
else{print " <a href=\"$fm->{SCRIPT}?dir=$sh$shDir$tmpDir$addQs\" class=\"filefolderlisting\">$tmp</a>";}
print "</div></td><td width=\"$col2\">&nbsp;</td><td width=\"$col3\" class=\"filefolderlisting\">&lt;$fm->{MESSAGES}->{DIR}&gt;</td>";
print "<td  width=\"33%\">&nbsp;" if $fm->{fileDescriptionOn} ;
print "<a href=\"javascript:notesview('$sh$shDir$tmpDir')\"class=\"filefolderlisting\">$note</a>" if  $note;
print "</td>" if $fm->{fileDescriptionOn} ;
print "<td width=\"12%\" class=\"filefolderlisting\">$dsort->{$_}->{date}</td>";
print "</tr>";
}
for(@skeys){
my $desc;
my $icon = $fm->getIcon($sort->{$_}->{ext});
print qq~<tr class=off onmouseover="sh(this)" onmouseout="shh(this)">\n<td  width="2%" height="20" align="center">
<input type=checkbox name=file value="$shDir$_" $disabled>
</td><td  nowrap width="$col1"><div>~;
my $note = $fm->getNote($dir."/".$_, 1) if $fm->{fileDescriptionOn};
my $txtnote = "<a href=\"javascript:notesview('$dir/$_')\"><img src=\"$fm->{htmlDataFolder}/note.gif\"></a>"  if $fm->{fileDescriptionOn} && $note;
if ($_=~m/(gz|tar)$/i){
my $tdir=$dir;
(my $tmpFile="$_")=~s/\&/%26/g;
$tmpFile=~s/#/%23/g;
if ($_=~m/^\(shared\)/){
($tdir, $tmpFile) = $fm->subDirFile($_);
#$tdir="(shared)".$dir;
}
(my $tname=$_)=~s/^\(shared\)//;
$tname=~s/^(.{65}).+/$1\.\.\./;
print "<a href='$script?opt=name&amp;dir=$tdir&r=$fm->{r}&gzfile=$tmpFile'><img src=\"$fm->{htmlDataFolder}/$Manager::fileType->{gz}\" border=0></a>$txtnote <a href='$script?opt=name&dir=$tdir&r=$fm->{r}&gzfile=$tmpFile' class=\"filefolderlisting\">$tname</a>\n";
}
else{
(my $fl = "$shDir$_")=~s/'/\\'/g;
(my $tf=$_)=~s/^\(shared\)//;
$tf=~s/^(.{65}).+/$1\.\.\./;
print "<a href=\"javascript:fview('$fl')\" >$icon
$txtnote <a href=\"javascript:fview('$fl')\" class=\"filefolderlisting\">$tf</a>\n";
}
if(length($sort->{$_}->{size})>7){
$sort->{$_}->{size}=~s/,//;
$sort->{$_}->{size} = sprintf("%.2f",$sort->{$_}->{size}/(1024*1024))." $fm->{MESSAGES}->{Mb}";
#$sort->{$_}->{size}=~s/\././;
}
elsif(length($sort->{$_}->{size})>3){
$sort->{$_}->{size}=~s/,//;
$sort->{$_}->{size} = sprintf("%.2f",$sort->{$_}->{size}/(1024))." $fm->{MESSAGES}->{Kb}";
}
else {$sort->{$_}->{size}.=" $fm->{MESSAGES}->{Kb}"}
print "</div></td><td  width=\"$col2\" class=\"filefolderlisting\">.$sort->{$_}->{ext}</td><td align=left  width=\"$col3\" class=\"filefolderlisting\">$sort->{$_}->{size}</td>";
print "<td  width=\"33%\">&nbsp;" if $fm->{fileDescriptionOn} ;
print "<a href=\"javascript:notesview('$dir/$_')\" class=\"filefolderlisting\">$note</a>" if  $note;
print "</td>" if $fm->{fileDescriptionOn} ;
print "<td  width=\"12%\" class=\"filefolderlisting\">$sort->{$_}->{date}</td>";
print "</tr>\n";
}
print "<tr><td height=\"90%\"><td></td></tr>";
print "</tbody></table><input type=\"hidden\" name=\"file\"><input type=\"hidden\" name=\"folder\"></div>";
print "</td></tr>";
print "<tr><td>";
print footer();
print "</table></body></html>";
sub footer{
my $tmp = qq~<div id="foot">
<span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{Taskbar},sizingMethod=scale);z-index:-1;position:absolute;left:0px;display:block;height:115px;width:100%;background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{Taskbar}) !important;background:none;"></span>
<br>
<table cellspacing="3" align="center">
<tr>~;
$tmp .= qq~  <th align="center"><a href="javascript:download()" title="$fm->{MESSAGES}->{download}" onmouseover="window.status='$fm->{MESSAGES}->{download}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{DownloadIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{DownloadIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{download}"></a></th>~ if $Rights->{r};
$tmp .= qq~  <th align="center"><a href="javascript:upload()" title="$fm->{MESSAGES}->{upload}" onmouseover="window.status='$fm->{MESSAGES}->{upload}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UploadIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UploadIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{upload}"></a></th>~ if $Rights->{u};
$tmp .= qq~  <th align="center"><a href="javascript:batch_download()" title="$fm->{MESSAGES}->{batch_download_zip}" onmouseover="window.status='$fm->{MESSAGES}->{batch_download_zip}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{ZipIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{ZipIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{batch_download_zip}"></a></th>~ if $Rights->{z};
#$tmp .= qq~  <th align="center"><a href="javascript:chmod()" title="$fm->{MESSAGES}->{chmod}" onmouseover="window.status='$fm->{MESSAGES}->{chmod}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{CHMODIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{CHMODIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{chmod}"></a></th>~ if $Rights->{c};
$tmp .= qq~  <th align="center"><a href="javascript:view()" title="$fm->{MESSAGES}->{preview}" onmouseover="window.status='$fm->{MESSAGES}->{preview}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{PreviewIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{PreviewIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{preview}"></a></th>~ if $Rights->{v};
$tmp .= qq~  <th align="center"><a href="javascript:pack()" title="$fm->{MESSAGES}->{pack}" onmouseover="window.status='$fm->{MESSAGES}->{pack}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{PackIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{PackIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{pack}"></a></th>~ if $Rights->{p};
$tmp .= qq~  <th align="center"><a href="javascript:unpack()" title="$fm->{MESSAGES}->{unpack}" onmouseover="window.status='$fm->{MESSAGES}->{unpack}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UnpackIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UnpackIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{unpack}"></a></th>~ if $Rights->{k};
$tmp .= qq~  <th align="center"><a href="javascript:hotlink()" title="$fm->{MESSAGES}->{hotlink}" onmouseover="window.status='$fm->{MESSAGES}->{hotlink}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{HotlinkIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{HotlinkIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{hotlink}"></a></th>~ if $Rights->{t};
$tmp .= qq~  <th align="center"><a href="javascript:notes()" title="$fm->{MESSAGES}->{notes}" onmouseover="window.status='$fm->{MESSAGES}->{notes}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{NotesIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{NotesIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{notes}"></a></th>~ if $Rights->{l};
$tmp .= qq~  <th align="center"><a href="javascript:copy()" title="$fm->{MESSAGES}->{copy}" onmouseover="window.status='$fm->{MESSAGES}->{copy}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{CopyIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{CopyIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{copy}"></a></th>~ if $Rights->{o};
$tmp .= qq~  <th align="center"><a href="javascript:rename()" title="$fm->{MESSAGES}->{rename}" onmouseover="window.status='$fm->{MESSAGES}->{rename}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{RenameIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{RenameIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{rename}"></a></th>~ if $Rights->{a};
$tmp .= qq~  <th align="center"><a href="javascript:move()" title="$fm->{MESSAGES}->{move}" onmouseover="window.status='$fm->{MESSAGES}->{move}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{MoveIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{MoveIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{move}"></a></th>~ if $Rights->{m};
$tmp .= qq~  <th align="center"><a href="javascript:editor()" title="$fm->{MESSAGES}->{editor}" onmouseover="window.status='$fm->{MESSAGES}->{editor}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{EditorIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{EditorIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{editor}"></a></th>~ if $Rights->{w};
$tmp .= qq~  <th align="center"><a href="javascript:mkdir()" title="$fm->{MESSAGES}->{mkdir}" onmouseover="window.status='$fm->{MESSAGES}->{mkdir}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{NewDirectoryIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{NewDirectoryIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{mkdir}"></a></th>~ if $Rights->{n};
$tmp .= qq~  <th align="center"><a href="javascript:delete_f()" title="$fm->{MESSAGES}->{delete}" onmouseover="window.status='$fm->{MESSAGES}->{delete}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{DeleteIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{DeleteIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{delete}"></a></th>~ if $Rights->{d};
$tmp .= qq~  <th align="center"><a href="javascript:logout()" title="$fm->{MESSAGES}->{exit}" onmouseover="window.status='$fm->{MESSAGES}->{exit}'; return true;" onmouseout="window.status=''; return true;" style="width:$fm->{IconWidth};height:$fm->{IconHeight};display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{ExitIcon}');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{ExitIcon}" width="$fm->{IconWidth}" height="$fm->{IconHeight}" border="0" alt="$fm->{MESSAGES}->{exit}"></a></th> ~;
$tmp .= " </tr>
<tr>";
$tmp .= qq~ <td><a href="javascript:download()" onmouseover="window.status='$fm->{MESSAGES}->{download}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{download}</a></td>~ if $Rights->{r};
$tmp .= qq~ <td><a href="javascript:upload()" onmouseover="window.status='$fm->{MESSAGES}->{upload}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{upload}</a></td>~ if $Rights->{u};
$tmp .= qq~ <td><a href="javascript:batch_download()" onmouseover="window.status='$fm->{MESSAGES}->{batch_download_zip}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{batch_download_zip}</a></td>~ if $Rights->{z};
#$tmp .= qq~ <td><a href="javascript:chmod()" onmouseover="window.status='$fm->{MESSAGES}->{chmod}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{chmod}</a></td>~ if $Rights->{c};
$tmp .= qq~ <td><a href="javascript:view()" onmouseover="window.status='$fm->{MESSAGES}->{preview}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{preview}</a></td>~ if $Rights->{v};
$tmp .= qq~ <td><a href="javascript:pack()" onmouseover="window.status='$fm->{MESSAGES}->{pack}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{pack}</a></td>~ if $Rights->{p};
$tmp .= qq~ <td><a href="javascript:unpack()" onmouseover="window.status='$fm->{MESSAGES}->{unpack}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{unpack}</a></td>~ if $Rights->{k};
$tmp .= qq~ <td><a href="javascript:hotlink()" onmouseover="window.status='$fm->{MESSAGES}->{hotlink}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{hotlink}</a></td>~ if $Rights->{t};
$tmp .= qq~ <td><a href="javascript:notes()"  onmouseover="window.status='$fm->{MESSAGES}->{notes}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{notes}</a></td>~ if $Rights->{l};
$tmp .= qq~ <td><a href="javascript:copy()" onmouseover="window.status='$fm->{MESSAGES}->{copy}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{copy}</a></td>~  if $Rights->{o};
$tmp .= qq~ <td><a href="javascript:rename()" onmouseover="window.status='$fm->{MESSAGES}->{rename}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{rename}</a></td>~  if $Rights->{a};
$tmp .= qq~ <td><a href="javascript:move()" onmouseover="window.status='$fm->{MESSAGES}->{move}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{move}</a></td>~  if $Rights->{m};
$tmp .= qq~ <td><a href="javascript:editor()" onmouseover="window.status='$fm->{MESSAGES}->{editor}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{editor}</a></td>~  if $Rights->{w};
$tmp .= qq~ <td><a href="javascript:mkdir()" onmouseover="window.status='$fm->{MESSAGES}->{mkdir}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{mkdir}</a></td>~  if $Rights->{n};
$tmp .= qq~ <td><a href="javascript:delete_f()" onmouseover="window.status='$fm->{MESSAGES}->{delete}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{delete}</a></td>~  if $Rights->{d};
$tmp .= qq~ <td><a href="javascript:logout()" onmouseover="window.status='$fm->{MESSAGES}->{exit}'; return true;" onmouseout="window.status=''; return true;">$fm->{MESSAGES}->{exit}</a></td> ~;
$tmp .= qq~</tr>
</table>
</div>
</form>
~;
return $tmp;
}
sub view{
my $file=$fm->getCurrentFile($fm->{CGI}->{file},'v',1);
$fm->logger("File ".$fm->getUserPath($fm->{CGI}->{file})." Previewed");
my ($fdir,$filename,$ext) = $fm->subDirFile($file);
if (!$fm->{CGI}->{play} && lc $ext eq 'mp3'){
my $link = "$script?action=view&dir=$fm->{CGI}->{dir}&play=1&file=$fm->{CGI}->{file}";
play($link,$filename);
}
my $contentType=$fm->getContentType($ext);
if ($contentType){
if ($contentType eq 'attachment'){print "Content-disposition: attachment; filename=$filename\n";}
else{
print "Content-Type: $contentType\n"
#print "Content-disposition: inline; filename=\"$filename\"\n" ;
}
print "Content-Length: ".(-s $file ) ."\n";
print "\n";
if($fm->{CGI}->{gzfile}){
my $tar = Archive::Tar->new("$fdir/$fm->{CGI}->{gzfile}",1);
my  @files = $tar->get_files($filename);
binmode STDOUT;
print $files[0]->{data};
exit;
}
elsif($filename=~m/\.s?html?$/i){
print "<BASE HREF=\"$fm->{htmlClientsFolder}/\">\n";
open(F, "$file") or error($fm->{MESSAGES}->{err_open_file});
binmode F;
binmode STDOUT;
while(<F>){print;}
close F;
}
else{
open(F, "$file") or error($fm->{MESSAGES}->{err_open_file});
binmode F;
binmode STDOUT;
while(<F>){print;}
close F;
}
exit;
}
else{
print "Content-Type: text/html;  charset=utf-8\n\n";
print "<html>\n<head>\n<title>$fm->{MESSAGES}->{preview}: $filename</title>\n</head>
<body topmargin=0 leftmargin=0><form>
<textarea readonly rows=25 cols=50 style=\"width:100%;height: 99%;\">";
open(F, "$file") or error($fm->{MESSAGES}->{err_open_file});
while(<F>){print;}
close F;
print "</textarea></form>\n</body>\n</html>";
}
exit;
}
sub error{
print "Content-Type: text/html; charset=utf-8\n\n";
print "<html><h3>$_[0]</h3></html>";
exit;
#die $_[0];
}
sub error_right{
my $mess = shift;
$fm->logger("$fm->{MESSAGES}->{no_right} '$mess'");
error ($fm->{MESSAGES}->{"no_right"}) ;
}
sub chmod_f{
my ($text, $mode);
$fm->{CGI}->{cmd}=eval("$fm->{CGI}->{cmd}") & 0777;
for($fm->getParam('file')){
$_=~m/\.([^\.]+)$/;
next if $fm->currentDisabled->{lc $1};
if ($fm->{CGI}->{cmd}){ chmod $fm->{CGI}->{cmd}, $fm->getCurrentFile($_, 'c'); }
else{
$text .="<input type=\"hidden\" name=\"file\" value=\"$_\" >"  if $_ ;
my @sb=stat($fm->getCurrentFile($_));
$mode= sprintf("%04o",$sb[2] & 0777);
$fm->logger($fm->getUserPath($_)." Chmod");
}
}
my $onload;
if($fm->{CGI}->{cmd}){$onload=" onload=\"go();\"";}
else{
$mode ||= "0644";
my $R;
my ($n,$u,$g,$o) = split("",$mode);
if ($u>=4){$u-=4; $R->{u}->{r}="checked"}
if ($u>=2){$u-=2; $R->{u}->{w}="checked"}
if ($u>=1){$u-=1; $R->{u}->{e}="checked"}
if ($g>=4){$g-=4; $R->{g}->{r}="checked"}
if ($g>=2){$g-=2; $R->{g}->{w}="checked"}
if ($g>=1){$g-=1; $R->{g}->{e}="checked"}
if ($o>=4){$o-=4; $R->{o}->{r}="checked"}
if ($o>=2){$o-=2; $R->{o}->{w}="checked"}
if ($o>=1){$o-=1; $R->{o}->{e}="checked"}
$text .= qq~
<div id="chmod" style="position:absolute;z-index:1;visibility:visible; top:15px;width:280px;height:245px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{CHMODIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{CHMODIcon}) !important;background:none;"></span></td>
<td class="subheader">$fm->{MESSAGES}->{chmod}</td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="270px" class="line"></td>
</tr>
</table>
<table align=center class="border">
<tr><td>$fm->{MESSAGES}->{mode}</td><td>$fm->{MESSAGES}->{user}</td><td>$fm->{MESSAGES}->{group}</td><td>$fm->{MESSAGES}->{world}</td></tr>
<tr><td>$fm->{MESSAGES}->{read}</td>
<td><input type=checkbox name="U" onclick="SetMod(this)" value="4" $R->{u}->{r}></td>
<td><input type=checkbox name="G" onclick="SetMod(this)" value="4" $R->{g}->{r}></td>
<td><input type=checkbox name="O" onclick="SetMod(this)" value="4" $R->{o}->{r}></td>
</tr>
<tr><td>$fm->{MESSAGES}->{write}</td>
<td><input type=checkbox name="U" onclick="SetMod(this)" value="2" $R->{u}->{w}></td>
<td><input type=checkbox name="G" onclick="SetMod(this)" value="2" $R->{g}->{w}></td>
<td><input type=checkbox name="O" onclick="SetMod(this)" value="2" $R->{o}->{w}></td>
</tr>
<tr><td>$fm->{MESSAGES}->{execute}</td>
<td><input type=checkbox name="U" onclick="SetMod(this)" value="1" $R->{u}->{e}></td>
<td><input type=checkbox name="G" onclick="SetMod(this)" value="1" $R->{g}->{e}></td>
<td><input type=checkbox name="O" onclick="SetMod(this)" value="1" $R->{o}->{e}></td>
</tr>
<tr><td>$fm->{MESSAGES}->{permission}</td><td colspan=3><input type=text name="cmd" size="4" value="$mode"></td></tr>
<tr><td colspan="4" align="center">
<input type="submit" value="$fm->{MESSAGES}->{chmod}">
<input type="button"  value=$fm->{MESSAGES}->{cancel} onclick="window.close()"></td></tr>
</table>
</div>
~;
};
print "Content-Type: text/html;  charset=utf-8\n\n";
my $data={
CONTENT=>$text,
TITLE=>$fm->{MESSAGES}->{chmod},
script => $fm->{SCRIPT},
ONLOAD => $onload,
dir => $fm->{CGI}->{dir},
};
print $fm->tmpToHtml($fm->{'tmpWndMain'},$data);
exit;
}
sub rename{
my $text;
if($fm->{CGI}->{cmd}){
my $path = $fm->getCurrentPath($fm->{CGI}->{file}, 'a');
$fm->{CGI}->{cmd}=~m/\.([^\.]+)$/;
error("$fm->{MESSAGES}->{err_rename_disabled}") if $fm->currentDisabled->{lc $1};
$fm->{CGI}->{old_cmd}=~m/\.([^\.]+)$/;
error("$fm->{MESSAGES}->{err_rename_disabled}") if $fm->currentDisabled->{lc $1};
chdir "$path";
rename  "$fm->{CGI}->{old_cmd}", "$fm->{CGI}->{cmd}" or error($!."$fm->{MESSAGES}->{err_rename_file}");
$fm->moveNotes("$path/$fm->{CGI}->{old_cmd}", "$path/$fm->{CGI}->{cmd}", 1);
$fm->asHtml(title=>'rename',close=>1);
}
else{
(my $filename=$fm->getCurrentFile($fm->{CGI}->{file}, 'a'))=~s!^.*[/\\]!!;
$text = qq~
<div id="rename" style="position:absolute;z-index:1;visibility:visible;top:15px;width:400px;height:50px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{RenameIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{RenameIcon}) !important;background:none;"></span></td>
<td class="subheader">$fm->{MESSAGES}->{rename}</td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
</tr>
</table>
<table width="100%">
<tr>
<td><input type="hidden" name="old_cmd" value="$filename">
&nbsp;$fm->{MESSAGES}->{name}: <input name="cmd" onkeydown="javascript:chkFrmrn();" onkeyup="javascript:chkFrmrn();" style="width: 300px"  value="$filename"></td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
<tr><td colspan="2" align="right">
<input type="submit" value="$fm->{MESSAGES}->{ok}"  class="button">
<input type="button" value="$fm->{MESSAGES}->{cancel}" onclick="window.close();" class="button"></td>
</tr>
</table>
</div>~;
}
$fm->asHtml(text=>$text, title=>"$fm->{MESSAGES}->{rename_file}");
}
sub mkdir{
my $path = $fm->getCurrentPath($fm->{CGI}->{file}, 'n');
if($fm->{CGI}->{cmd}){
mkdir "$path/$fm->{CGI}->{cmd}",0755 or $fm->error("$fm->{MESSAGES}->{err_create_new_dir} $!");
$fm->logger("Folder '".$fm->getUserPath("$path/$fm->{CGI}->{cmd}")."' Created");
$fm->addNote("$path/$fm->{CGI}->{cmd}", $fm->{CGI}->{fileDescription});
$fm->asHtml(title=>'mkdir',close=>1);
}
my $fileDesc=qq~<tr><td>&nbsp;$fm->{MESSAGES}->{description}: <input type=text name=fileDescription size="20" style="width:180pt" maxlength="32">~ if $fm->{fileDescriptionOn};
my $text = qq~
<div id="mkdir" style="position:absolute;z-index:1;visibility:visible;top:15px;width:400px;height:50px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{NewDirectoryIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{NewDirectoryIcon}) !important;background:none;"></span></td>
<td class="subheader">$fm->{MESSAGES}->{mkdir}</td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
</tr>
</table>
<table width="100%">
<tr>
<td>&nbsp;$fm->{MESSAGES}->{name}: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input name=cmd onkeydown="javascript:chkFrm();" onkeyup="javascript:chkFrm();" style="width:240px"></td></tr>$fileDesc</tr>
</table>
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
<tr><td colspan="2" align="right">
<input type=submit value="$fm->{MESSAGES}->{ok}"  class=button> <input type=button value=$fm->{MESSAGES}->{cancel} onclick="window.close()" class=button></td>
</table>
</div>~;
$fm->asHtml(text=>$text, title=>"$fm->{MESSAGES}->{new_dir}");
}
sub download{
my $file=$fm->getCurrentFile($fm->{CGI}->{file}, 'r');
(my $filename = $file) =~s!^.*[/\\]!!;
$file=~m/\.([^\.]+)$/;
error("$fm->{MESSAGES}->{err_downl_disabled}!") if $fm->currentDisabled->{lc $1};
$fm->logger("File ".$fm->getUserPath($fm->{CGI}->{file})." Downloaded");
if ($fm->{sendConfirmDownload}){
my $message="$file downloaded";
if($fm->{sendAsHtml}){
$message = $fm->get_record( $fm->read_file($fm->{templateDir}."/".$fm->{emlFileDownload}),
{
MESSAGE=>$message,
login=>$fm->currentUser->{login},
first=>$fm->currentUser->{first},
last=>$fm->currentUser->{last},
files=>join (', ',$filename),
}
);
}
$fm->male($fm->{toAdmin}, $fm->{fromAdmin}, "$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_downloaded}:", $message);
}
open(F, "$file") or error($fm->{MESSAGES}->{err_open_file});
binmode F;
print "Content-type: multipart/form-data;\n";
print "Content-length: " .( -s $file ). "\n";
print "Content-Disposition: attachment; filename=\"$filename\"\n\n";
binmode STDOUT;
while(<F>){print;}
close F;
exit;
}
sub delete{
        for($fm->getParam('file')){
        my $file=$fm->getCurrentFile($_, 'd',0);
        if ($file and -e $file){
        if (-d $file){File::Path::rmtree($file);}
        else{unlink $file;}
        $fm->deleteNote($file);
        $fm->logger("".$fm->getUserPath($file)." Deleted");
        }
        }
        print "Location: $fm->{SCRIPT}?".$fm->getQueryString()."\n\n";
}
sub batch_download{
my $zip = Archive::Zip->new();
$fm->{CGI}->{'zipname'} .=".zip" if $fm->{CGI}->{'zipname'}!~m/\.zip$/i;
$fm->logger("$fm->{CGI}->{'zipname'} Zipped & Downloaded");
for($fm->getParam('file')){
my $path=$fm->getCurrentFile($_, 'z', 1);
my ($folder,$file) = $fm->subDirFile($path);
chdir "$folder";
$fm->{fileList}=[];
if (-d $path){
chdir "$folder";
File::Find::find(\&treeFiles, "$path");
}
else{$zip->addFile( $path,$file );}
for(@{$fm->{fileList}}){
(my $name=$_)=~s/$folder//;
$name=~s/^\///;
if(-d $_){$zip->addDirectory( "$_", $name );}
else{$zip->addFile( "$_",$name );}
}
}
if ($fm->{sendConfirmDownload}){
my $message="$fm->getParam('file') downloaded";
if($fm->{sendAsHtml}){
$message = $fm->get_record( $fm->read_file($fm->{templateDir}."/".$fm->{emlFileDownload}),
{
MESSAGE=>$message,
login=>$fm->currentUser->{login},
first=>$fm->currentUser->{first},
last=>$fm->currentUser->{last},
files=>join(', ', $fm->getParam('file')),
}
);
}
$fm->male($fm->{toAdmin}, $fm->{fromAdmin}, "$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_downloaded}:", $message);
}
print "Content-type: application/zip\n";
print "Content-Disposition: inline; filename=\"$fm->{CGI}->{'zipname'}\"\n\n";
binmode STDOUT;
$zip->writeToFileHandle( *STDOUT, 0 );
exit;
}
sub treeFiles{
my $name=$File::Find::name;
return if $name=~m/\/\./;
push @{$fm->{fileList}},$name;
}
sub pack{
if($fm->{CGI}->{cmd} ){
my $tar = Archive::Tar->new();
for($fm->getParam('file')){
my $path=$fm->getCurrentFile($_, 'p', 1);
my ($folder,$file) = $fm->subDirFile($path);
chdir "$folder";
$tar->add_files($file);
if (-d $file){
$fm->{fileList}=[];
File::Find::find(\&treeFiles, $file);
$tar->add_files(@{$fm->{fileList}});
}
}
(my $filename = $fm->{CGI}->{cmd},$fm->{CGI}->{cmd1}) =~s/(\.tar)|(\.gz)//i;
$tar->write("$filename.tar") or error("$fm->{MESSAGES}->{err_create} $filename.tar");
binmode ("$filename.tar.gz"); # gzopen only sets it on the fd
my $gz = Compress::Zlib::gzopen("$filename.tar.gz", "wb") or error( "$fm->{MESSAGES}->{err_open_std}\n") ;
open (F,"$filename.tar")  or error("$fm->{MESSAGES}->{err_open} $filename.tar");
binmode F;
while(<F>){$gz->gzwrite($_)  or error( "$fm->{MESSAGES}->{err_write}\n") ;}
close (F);
$gz->gzclose;
unlink "$filename.tar";
$fm->logger("Archive File '$filename.tar.gz' Created");
$fm->asHtml(title=>'gzip',close=>1);
}
else{
my $path=$fm->getCurrentFile(($fm->getParam('file'))[0], 'p', 1);
my ($folder,$file) = $fm->subDirFile($path);
my $hidden;
my $size=0;
foreach($fm->getParam('file')) {
$hidden.=qq~<input type="hidden" name="file" value="$_">~;
$size += -s $fm->getCurrentFile($_, 'p', 1);
}
if ($size > 200*1024*1024){error("Files is to big for pack operation on this server!");}
my $text = qq~
<div id="Pack" style="position:absolute;z-index:1;visibility:visible;top:15px;width:400px;height:50px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{PackIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{PackIcon}) !important;background:none;"></span></td>
<td class="subheader">$fm->{MESSAGES}->{pack}</td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
</tr>
</table>
<table width="100%">
<tr>
<td>&nbsp;$fm->{MESSAGES}->{name}: <input name="cmd" style="width:300px" value=""><input TYPE="hidden" value="" NAME="cmd1">$hidden</td></tr>
</table>
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
<tr><td colspan="2" align="right"><input type="submit" value="$fm->{MESSAGES}->{ok}"  class="button">
<input type="button" value="$fm->{MESSAGES}->{cancel}" onclick="window.close()" class="button"></td>
</tr>
</table>
</div>
~;
$fm->asHtml(text=>$text, title=>"$fm->{MESSAGES}->{pack_file}");
}
}
sub unpack{
my $path=$fm->getCurrentFile($fm->{CGI}->{file}, 'k', 1);
my $text;
if($fm->{CGI}->{cmd}){
$fm->{CGI}->{cmd}=~s!/\*\.\*$!!;
$fm->{CGI}->{cmd}=~s!^/!!;
my $cmd = $fm->getCurrentPath($fm->{CGI}->{cmd}, 'k', 1);
chdir "$cmd" or error("Incorrect target path!");
my $tar = Archive::Tar->new($path,1);
if ($tar){
my  @files = $tar->list_files();
#check disabled files
my @tmp;
for (@files){push @tmp, $_ if $fm->allowFile($_)}
$tar->extract(@tmp);
$fm->logger("File ".$fm->getUserPath($fm->{CGI}->{file})." Unpacked");
}
else{error("Incorrect target path!")}
$fm->asHtml(title=>'gzip',close=>1);
}
elsif($fm->{CGI}->{file}!~m/\.tar/ && $fm->{CGI}->{file}!~m/\.gz/){
$text = qq~<div id="UnPack" style="position:absolute;z-index:1;visibility:visible;top:15px;width:400px;height:50px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UnpackIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UnpackIcon}) !important;background:none;"></span></td>
<td class="subheader">$fm->{MESSAGES}->{unpack}</td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
</tr>
</table>
<table width="100%">
<tr>
<td><font color=red><b>&nbsp;$fm->{CGI}->{file}</b>$fm->{MESSAGES}->{not_archive}</font>
</td></tr>
</table>
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
<tr><td colspan="2" align="right"><input type="button" value="$fm->{MESSAGES}->{cancel}" onclick="window.close()" class="button"></td>
</tr>
</table>
</div>~;
}
else{
my $slash='/' if $fm->{CGI}->{dir};
(my $dir=$fm->{CGI}->{dir})=~s/\(shared\)//;
$text = qq~
<div id="UnPack" style="position:absolute;z-index:1;visibility:visible;top:15px;width:400px;height:50px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UnpackIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UnpackIcon}) !important;background:none;"></span></td>
<td class="subheader">$fm->{MESSAGES}->{unpack}</td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
</tr>
</table>
<table width="100%">
<tr>
<td>&nbsp;$fm->{MESSAGES}->{directory}: <input type=hidden name=file value="$fm->{CGI}->{file}"><input name=cmd style="width:290px" value="$slash$dir/*.*">
</td></tr>
</table>
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
<tr><td colspan="2" align="right"><input type="submit" value="$fm->{MESSAGES}->{ok}"  class="button">
<input type="button" value="$fm->{MESSAGES}->{cancel}" onclick="window.close()" class="button"></td>
</tr>
</table>
</div>
~;}
$fm->asHtml(text=>$text, title=>"$fm->{MESSAGES}->{unpack_files}");
}
sub hotlink{
$fm->{CGI}->{limit}=~s/\D//g;
my $expire = time()+(60*60*24)*$fm->{CGI}->{limit} if $fm->{CGI}->{limit};
my ($file,$hotlink,$hotlinknormal) = $fm->setHotLink($fm->{CGI}->{file},$expire,$fm->{CGI}->{pwd});
my $urifile = uri_escape($file);
$fm->logger("File ".$fm->getUserPath($fm->{CGI}->{file})." Hotlinked");
my $add = '&l='.$expire if $fm->{CGI}->{limit};
$add.= '&p=1' if $fm->{CGI}->{pwd};
$hotlinknormal = "$fm->{scriptPath}/$fm->{SCRIPT}?file=$urifile&link=$hotlink&a=".$fm->currentUser->{id}.$add;
$hotlink = "$fm->{scriptPath}/$fm->{SCRIPT}?file=$urifile%26link=$hotlink%26a=".$fm->currentUser->{id}.$add;
my $option;
for (1,2,3,4,5,6,7,10,20,30,60,90){
$option .= "<option ".($fm->{CGI}->{limit} eq $_ ? 'selected':'').">$_</option>";
}
my $script = qq~
<script language="javascript" type="text/javascript">
function copy_clip(txt)
{
if (window.clipboardData)
{
window.clipboardData.setData("Text", txt);
}
}
function replaceCharacters() {
var origString = document.wndForm.inTB.value;
var inChar = document.wndForm.inC.value;
var outChar = document.wndForm.outC.value;
var newString = origString.split(inChar);
newString = newString.join(outChar);
document.wndForm.link.value = newString;
}
function sendmail()
{
location.href = "mailto:?Subject=" + "$fm->{MESSAGES}->{re} $fm->{MESSAGES}->{hotlink}"
+ "&Body=" + escape(document.wndForm.link.value);
}
function writeText (form) {
wndForm.inTB.value = "$hotlinknormal"
}
</script>~;

my $text = qq~
<input type="hidden" name="file" value="$fm->{CGI}->{file}">
<div id="hotlink" style="position:absolute;z-index:1;visibility:visible; top:15px;width:400px;height:25px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{HotlinkIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{HotlinkIcon}) !important;background:none;"></span></td>
<td class="subheader">$fm->{MESSAGES}->{hotlink}</td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
</tr>
</table>
<table>
<tr>
<td>
<input name="inTB" type="hidden" id="inTB" value="">
<input name="inC" type="hidden" id="inC" value=" ">
<input name="outC" type="hidden" id="outC" value="%20">
&nbsp;$fm->{MESSAGES}->{hotlink}: <input name="link" style="width: 260px" id = "txt" value=""> <input type="button" class=button value=" -> " onclick="window.open ('$hotlinknormal')"></td>
</tr>
<tr><td>&nbsp;$fm->{MESSAGES}->{password}: <input type="password" name="pwd" style="width: 160px" value="$fm->{CGI}->{pwd}">
$fm->{MESSAGES}->{Days}:
<select name="limit">
<option value="">--</option>
$option
</select>
 <input type="submit" class=button value="  +  ">
</td>
</tr>
</table>
<table wi
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
</tr>
</table>
<table width="100%" align="center">
<tr>
<td><a href="http://del.icio.us/post?url=$hotlinknormal" target="_blank" title="del.icio.us" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Delicious.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Delicious.png" width="31px" height="34px" border="0" alt="del.icio.us"></a><a href="http://del.icio.us/post?url=$hotlinknormal" target="_blank" title="del.icio.us">&nbsp;del.icio.us</a></td>
<td><a href="http://furl.net/storeIt.jsp?u=$hotlinknormal" target="_blank" title="Furl" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Furl.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Furl.png" width="31px" height="34px" border="0" alt="Furl"></a><a href="http://furl.net/storeIt.jsp?u=$hotlinknormal" target="_blank" title="Furl">&nbsp;Furl</a></td>
<td><a href="http://myweb2.search.yahoo.com/myresults/bookmarklet?u=$hotlink" target="_blank" title="Yahoo! My Web" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Yahoo-My-Web.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Yahoo-My-Web.png" width="31px" height="34px" border="0" alt="Yahoo! My Web"></a><a href="http://myweb2.search.yahoo.com/myresults/bookmarklet?u=$hotlink" target="_blank" title="Yahoo! My Web">&nbsp;Yahoo! My Web</a></td>
</tr>
<tr>
<td><a href="http://www.google.com/bookmarks/mark?op=edit&amp;bkmk=$hotlink" target="_blank" title="Google" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Google.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Google.png" width="31px" height="34px" border="0" alt="Google"></a><a href="http://www.google.com/bookmarks/mark?op=edit&amp;bkmk=$hotlink" target="_blank" title="Google">&nbsp;Google</a></td>
<td><a href="http://blinklist.com/index.php?Action=Blink/addblink.php&amp;Url=$hotlinknormal" target="_blank" title="BlinkList" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/BlinkList.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/BlinkList.png" width="31px" height="34px" border="0" alt="BlinkList"></a><a href="http://blinklist.com/index.php?Action=Blink/addblink.php&amp;Url=$hotlinknormal" target="_blank" title="BlinkList">&nbsp;BlinkList</a></td>
<td><a href="http://blogmarks.net/my/new.php?mini=1&amp;url=$hotlink" target="_blank" title="Blogmarks" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/BlogMarks.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/BlogMarks.png" width="31px" height="34px" border="0" alt="Blogmarks"></a><a href="http://blogmarks.net/my/new.php?mini=1&amp;url=$hotlink" target="_blank" title="Blogmarks">&nbsp;Blogmarks</a></td>
</tr>
<tr>
<td><a href="http://digg.com/submit?phase=2&amp;url=$hotlink" target="_blank" title="Digg" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Digg.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Digg.png" width="31px" height="34px" border="0" alt="Digg"></a><a href="http://digg.com/submit?phase=2&amp;url=$hotlink" target="_blank" title="Digg">&nbsp;Digg</a></td>
<td><a href="http://www.stumbleupon.com/submit?url=$hotlinknormal" target="_blank" title="StumbleUpon" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Stumbleupon.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Stumbleupon.png" width="31px" height="34px" border="0" alt="StumbleUpon"></a><a href="http://www.stumbleupon.com/submit?url=$hotlinknormal" target="_blank" title="StumbleUpon">&nbsp;StumbleUpon</a></td>
<td><a href="http://www.facebook.com/sharer.php?u=$hotlink" target="_blank" title="FaceBook" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/FaceBook.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/FaceBook.png" width="31px" height="34px" border="0" alt="FaceBook"></a><a href="http://www.facebook.com/sharer.php?u=$hotlink" target="_blank" title="FaceBook">&nbsp;FaceBook</a></td>
</tr>
<tr>
<td><a href="http://www.technorati.com/faves?add=$hotlinknormal" target="_blank" title="Technorati" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Technorati.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Technorati.png" width="31px" height="34px" border="0" alt="Technorati"></a><a href="http://www.technorati.com/faves?add=$hotlinknormal" target="_blank" title="Technorati">&nbsp;Technorati</a></td>
<td><a href="http://www.newsvine.com/_wine/save?u=$hotlinknormal" target="_blank" title="Newsvine" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Newsvine.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Newsvine.png" width="31px" height="34px" border="0" alt="Newsvine"></a><a href="http://www.newsvine.com/_wine/save?u=$hotlinknormal" target="_blank" title="Newsvine">&nbsp;Newsvine</a></td>
<td><a href="http://reddit.com/submit?url=$hotlink" target="_blank" title="reddit" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/reddit.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/reddit.png" width="31px" height="34px" border="0" alt="reddit"></a><a href="http://reddit.com/submit?url=$hotlink" target="_blank" title="reddit">&nbsp;reddit</a></td>
</tr>
<tr>
<td><a href="http://ma.gnolia.com/bookmarklet/add?url=$hotlinknormal" target="_blank" title="ma.gnolia" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/magnolia.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/magnolia.png" width="31px" height="34px" border="0" alt="ma.gnolia"></a><a href="http://ma.gnolia.com/bookmarklet/add?url=$hotlinknormal" target="_blank" title="ma.gnolia">&nbsp;ma.gnolia</a></td>
<td><a href="http://tailrank.com/share/?link_href=$hotlinknormal" target="_blank" title="Tailrank" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Tailrank.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/Tailrank.png" width="31px" height="34px" border="0" alt="Tailrank"></a><a href="http://tailrank.com/share/?link_href=$hotlinknormal" target="_blank" title="Tailrank">&nbsp;Tailrank</a></td>
<td><a href="http://view.nowpublic.com/public_view?src=$hotlink" target="_blank" title="NowPublic" style="width:31px;height:34px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/NowPublic.png');cursor:pointer;"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/NowPublic.png" width="31px" height="34px" border="0" alt="NowPublic"></a><a href="http://view.nowpublic.com/public_view?src=$hotlink" target="_blank" title="NowPublic">&nbsp;NowPublic</a></td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="390px" class="line"></td>
<tr><td colspan="2" align="right">
<input type="button" class=button value="Email $fm->{MESSAGES}->{hotlink}" onClick="sendmail();"></td>
</tr>
</table>
</form>
</div>
~;
$fm->asHtml(text=>$text, title=>"$fm->{MESSAGES}->{hotlink}",ONLOAD=>"onload=\"writeText(this.form); replaceCharacters();\"",JSCRIPT=>$script);
}
sub notes{
my $right = $fm->{CGI}->{del}||$fm->{CGI}->{edit}||$fm->{CGI}->{Submit} ? 'l':0;
my $path=$fm->getCurrentFile($fm->{CGI}->{file}, $right, 1);
my ($folder,$file) = $fm->subDirFile($fm->{CGI}->{file});
$file=~s/\(shared\)//;
if($fm->{CGI}->{del}){
$fm->deleteNoteById($fm->{CGI}->{del});
print "Location: $fm->{SCRIPT}?action=notes&file=$fm->{CGI}->{file}&r=1\n\n";
exit;
}
if( $fm->{CGI}->{edit}){
$fm->saveNote(file=>$path,note=>$fm->{CGI}->{note},id=>$fm->{CGI}->{edit});
print "Location: $fm->{SCRIPT}?action=notes&file=$fm->{CGI}->{file}&r=1\n\n";
exit;
}
if($fm->{CGI}->{Submit} && !$fm->{CGI}->{edit}){
$fm->saveNote(file=>$path, note=>$fm->{CGI}->{note});
$fm->logger("Note added to ".$fm->getUserPath($fm->{CGI}->{file})."");
print "Location: $fm->{SCRIPT}?action=notes&file=$fm->{CGI}->{file}&r=1\n\n";
exit;
}
my $notes = $fm->getNotes($path);
my $icon = $fm->getIcon($path,1);
my $txtNote;
for (@$notes){
$txtNote.="<b>$_->{user}</b> $_->{date} ";
$txtNote.="<a href=\"#editnote\" onclick=\"set_edit('$_->{id}')\"class=Menucss><b>$fm->{MESSAGES}->{edit}</b></a>
<a href=\"$fm->{SCRIPT}?action=notes&amp;file=$fm->{CGI}->{file}&amp;del=$_->{id}\" onclick=\"return confirm('$fm->{MESSAGES}->{sure_del_note}')\"class=Menucss><b>$fm->{MESSAGES}->{delete}</b></a>" if $_->{userId} eq $fm->currentUser->{id};
$txtNote.="<br><div id=\"edit_$_->{id}\" style=\"margin-left:5px;\">$_->{note}</div><hr style=\"width: 472px\" size=\"1\">\n";
}
my $text = qq~
<div id="notes" style="position:absolute;z-index:1;visibility:visible; top:15px;width:490px;height:520px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{NotesIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{NotesIcon}) !important;background:none;"></span></td>
<td class="subheader">$fm->{MESSAGES}->{notes}</td>
</tr>
</table>
<table width="99%">
<tr>
<td><hr width="472px" class="line"></td>
</tr>
</table>
<table width="99%">
<tr>
<td><b>&nbsp;$fm->{MESSAGES}->{name}:</b> $file</td>
</tr>
</table>
<table width="99%">
<tr>
<td><hr width="472px" class="line"></td>
</tr>
</table>
<table width="99%">
<tr>
<td>&nbsp;$txtNote</td>
</tr>
</table>
<script type="text/javascript">
function set_edit(id){
document.getElementById('edit').value=id;
var note = document.getElementById('edit_'+id).innerHTML;
myRe = /<br>/ig;
document.getElementById('note').value = note.replace(myRe,"\\n");
}
</script>
<table width="99%">
<tr>
<td><a name="editnote">
<input type="hidden" name="file" value="$fm->{CGI}->{file}">
<input type="hidden" name="edit" id="edit" value="">
<br><b>&nbsp;$fm->{MESSAGES}->{description}:</b><textarea name="note" rows="10" cols="65" id="note" style="width:100%; height:120" onKeyUp="this.form.Submit.disabled=(this.value.length>0)?false:true;"></textarea></a></td>
</tr>
</table>
<table width="99%">
<tr>
<td><hr width="472px" class="line"></td>
<tr><td colspan="2" align="right">
<input type="submit" name="Submit" value=" $fm->{MESSAGES}->{save} "  disabled>
<input type="button" value="$fm->{MESSAGES}->{cancel}" onclick="window.close();"></td>
</tr>
</table>
</div>
~;
$fm->asHtml(text=>$text, title=>"$file :: $fm->{MESSAGES}->{notes}", ONLOAD=>"onload=\"opener.location.reload();\"");
}
sub edit{
my $path=$fm->getCurrentFile($fm->{CGI}->{file}, 'w', 1);
my ($folder,$file) = $fm->subDirFile($path);
if($fm->{CGI}->{submitSave} || $fm->{CGI}->{closeSave} || $fm->{CGI}->{closeExit}){
$fm->{CGI}->{content}=~s/\r//gs;
open (F, ">$path") or error($fm->{MESSAGES}->{err_open_file});
print F $fm->{CGI}->{content};
close F;
$fm->logger("'".$fm->getUserPath($fm->{CGI}->{file})."' Edited");
}
print "Content-Type: text/html; charset=utf-8\n\n";
print qq~
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>$file</title>
<link rel="stylesheet" type="text/css" href="$fm->{htmlDataFolder}/fm.css">
<script type="text/javascript" src="$fm->{htmlDataFolder}/fm.js"></script>
\n~;
unless ($fm->{CGI}->{closeSave} || $fm->{CGI}->{closeExit}){
print qq~<script type="text/javascript">
var isClose = 0;
function closeWnd(){
if (isClose){
if (confirm("$fm->{MESSAGES}->{save_changes}")){
document.myform.closeExit.value="1";
document.myform.submit();
isClose=null;
}
else{isClose=null; window.close();}
}
else{isClose=null; window.close();}
}
</script>
~;
 }
print qq~<script type="text/javascript" src="$fm->{editorSrc}"></script>\n~ if $fm->{useWysiwig};
print qq~</head><body ~;
print qq~ onload="go()"~ if $fm->{CGI}->{closeSave} || $fm->{CGI}->{closeExit};
print qq~ background="$fm->{htmlDataFolder}/toolsLine.png">~ unless $fm->{useWysiwig};
print qq~
<form action="$fm->{SCRIPT}" method="post" name="myform">
<input type="hidden" name="action" value="edit">
<input type="hidden" name="closeExit">
<input type="hidden" name="file" value="$fm->{CGI}->{file}">
<textarea id="content1" name="content" rows="25" cols="50" style="width:100%" onchange="javascript:isClose=1;">~;
open(F, "$path") or error($fm->{MESSAGES}->{err_open_file});
while(<F>){
$_=~s!<!&#60;!g;
$_=~s!>!&#62;!g;
print;
}
close F;
print qq~</textarea><p align="center">
<input type="reset">
<input type="submit" name="submitSave" value="$fm->{MESSAGES}->{save}" onclick="javascript:isClose=0;">
<input type="submit" name="closeSave" value="$fm->{MESSAGES}->{save_close}"  onclick="javascript:isClose=0;">
<input type="button" value="$fm->{MESSAGES}->{cancel}" onclick="closeWnd();"></p></form>~;
print qq~<script type="text/javascript">
generate_wysiwyg('content1');
</script>~ if $fm->{useWysiwig};
print qq~</body></html>~;
exit;
}
sub userarea{
my $txt ="";
if($fm->{CGI}->{pw} eq 'change'){
my $error ='';
chomp $fm->{CGI}->{newpw};
chomp $fm->{CGI}->{newpw2};
$error .="<center><br><b class=error>$fm->{MESSAGES}->{err_old_pw}<br></b></center>" if !$fm->{CGI}->{oldpw} ;
$error .="<center><br><b class=error>$fm->{MESSAGES}->{err_blank_pw}<br></b></center>" unless $fm->{CGI}->{newpw};
$error .="<center><br><b class=error>$fm->{MESSAGES}->{err_new_pw}<br></b></center>" if $fm->{CGI}->{newpw} ne $fm->{CGI}->{newpw2};
$error .="<center><br><b class=error>$fm->{MESSAGES}->{err_old_pw}<br></b></center>" unless  $fm->checkPassword($fm->{CGI}->{oldpw}, $fm->currentUser->{password});
unless ($error){
$fm->updatePassword($fm->{CGI}->{newpw});
$fm->logger("Changed Password");
print "Location: $fm->{SCRIPT}?action=userarea\n\n";
exit;
}
$txt = $error."<br><br><center><a href=javascript:history.back()>$fm->{MESSAGES}->{back}</a>";
}
elsif ($fm->{CGI}->{pw} eq 'new'){
$txt = qq~
<form action="$fm->{SCRIPT}" method="post">
<input type="hidden" name="action" value="userarea">
<input type="hidden" name=pw value="change">
<table class="form" cellspacing="2" cellpadding="2" border="0" width="549" align="center">
<tr>
<td></td>
<tr>
<td></td>
<tr>
<td class="greybox" colspan="2"><b>$fm->{MESSAGES}->{change_password}:</b></td></tr>
<tr>
<td width="100">$fm->{MESSAGES}->{old_password}:</td>
<td><input style="width: 250px" type="password" name="oldpw"></td></tr>
<tr>
<td>$fm->{MESSAGES}->{new_password}:</td>
<td><input style="width: 250px" type="password" name="newpw"></td>
<tr>
<td>$fm->{MESSAGES}->{retype_password}:</td>
<td><input style="width: 250px" type="password" name="newpw2"></td>
<tr><td colspan="2" align="right"><input type="submit" value="$fm->{MESSAGES}->{ok}">
<input type="button" onclick="window.close()" value="$fm->{MESSAGES}->{cancel}"></td></tr>
</table>
</form>
~;
}
elsif($fm->{CGI}->{email} eq 'change'){
my $oldEmail = $fm->currentUser->{email};
if ($fm->updateEmail($fm->{CGI}->{userEmail})){
$fm->logger("Changed email address from '$oldEmail' to '".$fm->currentUser->{email}."'");
my $message = "Client: $fm->{currentUser}->{login}\nOld Email: $oldEmail\nNew email: $fm->{CGI}->{userEmail}\n";
$fm->male($fm->{toAdmin}, $fm->{fromAdmin}, "Client has changed their Email Address", $message) if $fm->{sendConfirmChEmail};
print "Location: $fm->{SCRIPT}?action=userarea\n\n";
exit;
}
else{error("Can't change email!");}
}
elsif($fm->{CGI}->{email} eq 'new'){
$txt = qq~
<form action="$fm->{SCRIPT}" method="post">
<input type="hidden" name="action" value="userarea">
<input type="hidden" name="email" value="change">
<table class="form" cellspacing="2" cellpadding="2" border="0" width="549" align="center">
<tr>
<td></td>
<tr>
<td></td>
<tr>
<td class="greybox" colspan="2"><b>$fm->{MESSAGES}->{ch_eml}:</b></td></tr>
<tr>
<td width="100">$fm->{MESSAGES}->{new_eml}:</td>
<td><input style="width: 300px" type="text" name="userEmail"></td></tr>
<tr><td colspan="2" align="right">
<input type="submit" value="$fm->{MESSAGES}->{ok}">
<input type="button" onclick="window.close()" value="$fm->{MESSAGES}->{cancel}"></td></tr>
</table>
</form>
~;
}
else{
my $user = $fm->currentUser();
my $used = $fm->usedSpace();
$user->{expired}||='&#8734;';
$used = $used? sprintf('%0.2F',$used/1024)." $fm->{MESSAGES}->{Mb}" : "-";
my $quote = $user->{diskquota}? "$user->{diskquota} $fm->{MESSAGES}->{Mb}":"&#8734;";
$txt =qq~
<table class="form" cellspacing="2" cellpadding="2" border="0" width="549" align="center">
<tr>
<td></td>
<tr>
<td></td>
<tr>
<td class="greybox" colspan="2"><b>$fm->{MESSAGES}->{client_details}:</b></td></tr>
<tr>
<td width="100">$fm->{MESSAGES}->{client_username}:</td>
<td>$user->{login}</td></tr>
<tr>
<td width="100">$fm->{MESSAGES}->{client_password}:</td>
<td>******* &nbsp; <a href="$fm->{SCRIPT}?action=userarea&amp;pw=new">[<b>$fm->{MESSAGES}->{change}</b>]</a></td></tr>
<tr><td>$fm->{MESSAGES}->{client_folder}:</td>
<td>/$user->{home}</td></tr>
<tr><td>$fm->{MESSAGES}->{disc_quota}:</td><td>$quote $fm->{MESSAGES}->{Mb}</td></tr>
<tr><td valign=top>$fm->{MESSAGES}->{disabled_files}:</td>
<td>$user->{protect}</td></tr>
<tr><td>$fm->{MESSAGES}->{expired_date}:</td><td>$user->{expired}</td></tr>
<tr>
<td class="greybox" colspan="2"><b>$fm->{MESSAGES}->{groups}:</b></td></tr>
<tr>
<td colspan="2">~.(ref $user->{groups} eq 'ARRAY'? join(', ',@{$user->{groups}}):$user->{groups}).qq~</td></tr>
<tr>
<td class="greybox" colspan="2"><b>$fm->{MESSAGES}->{rights}:</b></td></tr>
<tr><td colspan="2">
<table border="0" cellpadding="0" width="100%"><tr>
<td><input disabled type="checkbox" name="rights" value="u" $user->{RIGHTS_BOX}->{u}>$fm->{MESSAGES}->{upload}</td>
<td><input disabled type="checkbox" name="rights" value="r" $user->{RIGHTS_BOX}->{r}>$fm->{MESSAGES}->{download}</td>
<td><input disabled type="checkbox" name="rights" value="z" $user->{RIGHTS_BOX}->{z}>$fm->{MESSAGES}->{batch_download_zip}</td>
</tr>
<tr>
<td><input disabled type="checkbox" name="rights" value="m" $user->{RIGHTS_BOX}->{m}>$fm->{MESSAGES}->{move}</td>
<td><input disabled type="checkbox" name="rights" value="o" $user->{RIGHTS_BOX}->{o}>$fm->{MESSAGES}->{copy}</td>
<td><input disabled type="checkbox" name="rights" value="a" $user->{RIGHTS_BOX}->{a}>$fm->{MESSAGES}->{rename}</td>
</tr>
<tr>
<td><input disabled type="checkbox" name="rights" value="v" $user->{RIGHTS_BOX}->{v}>$fm->{MESSAGES}->{preview}</td>
<td><input disabled type="checkbox" name="rights" value="t" $user->{RIGHTS_BOX}->{t}>$fm->{MESSAGES}->{hotlink}</td>
<td><input disabled type="checkbox" name="rights" value="c" $user->{RIGHTS_BOX}->{c}>$fm->{MESSAGES}->{chmod}</td>
</tr>
<tr>
<td><input disabled type="checkbox" name="rights" value="p" $user->{RIGHTS_BOX}->{p}>$fm->{MESSAGES}->{pack}</td>
<td><input disabled type="checkbox" name="rights" value="k" $user->{RIGHTS_BOX}->{k}>$fm->{MESSAGES}->{unpack}</td>
<td><input disabled type="checkbox" name="rights" value="n" $user->{RIGHTS_BOX}->{n}>$fm->{MESSAGES}->{mkdir}</td>
</tr>
<tr>
<td><input disabled type="checkbox" name="rights" value="w" $user->{RIGHTS_BOX}->{w}>$fm->{MESSAGES}->{editor}</td>
<td><input disabled type="checkbox" name="rights" value="l" $user->{RIGHTS_BOX}->{l}>$fm->{MESSAGES}->{notes}</td>
<td><input disabled type="checkbox" name="rights" value="d" $user->{RIGHTS_BOX}->{d}>$fm->{MESSAGES}->{delete}</td>
</tr>
</table>
</td>
</tr>
<tr>
<td class="greybox" colspan="2"><b>$fm->{MESSAGES}->{contact_details}:</b></td></tr>
<tr>
<td>$fm->{MESSAGES}->{company_name}:</td>
<td>$user->{company}</td></tr>
<tr>
<td>$fm->{MESSAGES}->{first_name}:</td>
<td>$user->{first}</td></tr>
<tr>
<td>$fm->{MESSAGES}->{last_name}:</td>
<td>$user->{last}</td></tr>
<tr>
<td>$fm->{MESSAGES}->{address}:</td>
<td>$user->{address}</td></tr>
<tr>
<td>$fm->{MESSAGES}->{city}:</td>
<td>$user->{city}</td></tr>
<tr>
<td>$fm->{MESSAGES}->{state}:</td>
<td>$user->{state}</td></tr>
<tr>
<td>$fm->{MESSAGES}->{zip}:</td>
<td>$user->{zip}</td></tr>
<tr>
<td>$fm->{MESSAGES}->{country}:</td>
<td>$user->{country}</td></tr>
<tr>
<td>$fm->{MESSAGES}->{email}:</td>
<td>$user->{email}  &nbsp; <a href="$fm->{SCRIPT}?action=userarea&amp;email=new">[<b>$fm->{MESSAGES}->{change}</b>]</a></td></tr>
<tr>
<td>$fm->{MESSAGES}->{phone}:</td>
<td>$user->{phone}</td></tr>
<tr>
<td>$fm->{MESSAGES}->{fax}:</td>
<td>$user->{fax}</td></tr>
<tr>
<td colspan="2" align="right">
<br><input type="button" onclick="window.close()" value="$fm->{MESSAGES}->{cancel}"></td>
  </tr>
</table>
~;
}
print "Content-type: text/html; charset=utf-8\n\n";
print qq~
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>$fm->{MESSAGES}->{client_details}</title>
<link rel="stylesheet" type="text/css" href="$fm->{htmlDataFolder}/fm.css">
<script src="$fm->{htmlDataFolder}/css_browser_selector.js" type="text/javascript"></script>
</head>
<body>
$txt
</body></html>
~;
exit;
}
sub about{
print "Content-type: text/html; charset=utf-8\n\n";
print qq~
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>$fm->{FileManagerName}</title>
<meta http-equiv="imagetoolbar" content="false">
<style type="text/css">
.fsx01 {font-size: 11px;}
.txdec {text-decoration: none;}
body {margin:0;height:100%;width:100%; overflow-x: hidden; overflow-y: hidden;}
</style>
</head>
<body>
<div id="Background" style="position:absolute;z-index:1;visibility:visible; left:0px;top:0px;width:384px;height:321px;">
<img src="$fm->{htmlLogoFolder}/$fm->{AboutFileManager}" alt="" border=0 width="384" height="321">
</div>
<div id="Logo" style="position:absolute;z-index:1;visibility:visible; left:82px;top:40px;width:220px;height:88px;">
<a style="width:220px;height:88px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlLogoFolder}/$fm->{FileManagerLogo}');"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlLogoFolder}/$fm->{FileManagerLogo}" width="220px" height="88px" border="0" alt=""></a>
</div>
<div id="Copyright" style="position:absolute;z-index:1;visibility:visible; left:63px;top:145px;width:258px;height:142px;">
<a style="width:258px;height:142px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='$fm->{htmlLogoFolder}/$fm->{Copyright}');"><img style="filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"src="$fm->{htmlLogoFolder}/$fm->{Copyright}" width="258px" height="142px" border="0" alt=""></a>
</div>
<div id="Version" style="position:absolute;z-index:3;visibility:visible; left:302px;top:81px;width:164px;height:19px;">
<font face="Arial" class="fsx01" color="#3A3A3A"><B>$fm->{Version}<br></B></font></div>
<div id="RegisteredOwner" style="position:absolute;z-index:2;visibility:visible; left:64px;top:202px;width:258px;height:18px; text-decoration:none; border-bottom:1px dotted #666666;">
<font face="Arial" class="fsx01" color="#666666"><b>$fm->{RegisteredOwner}</b><br></font>
</div>
</body>
</html>
~;
exit;
}
sub copy_f{
my $move=shift;
my $right = $move? 'm':'o';
if($fm->{CGI}->{cmd}){
my @old = $fm->getParam('old_cmd');
my $fname=0;
$fm->{CMD} = $fm->getCurrentFile($fm->{CGI}->{folder}.$fm->{CGI}->{cmd}, $right, 1);
if ($fm->{CMD}=~s/(\/|\*\.\*)$/\//){$fname = 0;}
elsif(@old==1){ $fname = 1;}
for(@old){
my $path=$fm->getCurrentFile($_, $right, 1);
my ($folder,$file) = $fm->subDirFile($path);
$fm->{HOME}=$fm->getCurrentPath();
#die "$path, $fm->{CMD}/$file :".$fm->{CGI}->{folder}.$fm->{CGI}->{cmd};
next if $fm->_eqFile("$path", "$fm->{CMD}/$file");
if(-d "$path"){

        File::Path::mkpath("$path/$file", 0, 0755) or error("Can't create folder $!") unless -d "$path/$file";

        chdir "$fm->{HOME}";
        (my $target="$fm->{CMD}/$file") =~s/\/+/\//g;
        $target =~s/\/$//;
        File::Find::find(
                sub  {
                        (my $name = $File::Find::name)=~s/$fm->{HOME}//;
                        (my $curr = "$fm->{HOME}/$name") =~s/\/+/\//g;
                        return if $curr=~ m/$target/x;
                        if (-d "$File::Find::name"){
                                File::Path::mkpath("$fm->{CMD}/$name", 0, 0755) unless -d "$fm->{CMD}/$name";
                        }
                        else{
                                File::Copy::copy("$File::Find::name", "$fm->{CMD}/$name");
                        }
                }
        , $path);

        File::Path::rmtree($path) if $move && !$fm->_eqFile($path, $fm->{CMD});
        $fm->moveNotes($path,"$fm->{CMD}/$file",$move);
}
else{
my $folder = $fname?  "$fm->{CMD}" : "$fm->{CMD}/$file";
my $op = File::Copy::copy("$path", "$fm->{CMD}/$file");
$fm->moveNotes($path,"$fm->{CMD}/$file",$move);
unlink "$path" if $move && $op;
}
}
for (@old){$_=$fm->getUserPath($_)};
$fm->logger("'".(join ', ', @old)."' ".($move? 'moved':'copied')." to '".$fm->getUserPath($fm->{CMD})."'");
$fm->asHtml(title=>'copy', close=>1);
}
my @files = $fm->getParam('file');
my $path=$fm->getCurrentFile($files[0], $right, 1);
my ($folder,$file) = $fm->subDirFile($path);
my $filename = '/';
my $filenames = join (', ',@files);
$filenames=~s/^(.{40}).*/$1\.\.\./;
my $whichpage = ($move?$fm->{MESSAGES}->{move}:$fm->{MESSAGES}->{copy});
my $text = qq~
<div id="copy" style="position:absolute;z-index:1;visibility:visible;top:15px;width:480px;height:400px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$whichpage.png,sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$whichpage.png) !important;background:none;"></span></td>
<td class="subheader">$whichpage</td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr align="left" width="392px" class="line"></td>
</tr>
</table>
<table width="100%">
<tr><td>&nbsp;~.
($move?$fm->{MESSAGES}->{move}:$fm->{MESSAGES}->{copy}).qq~ <b>$filenames</b> $fm->{MESSAGES}->{to}:</td></tr>
<tr><td nowrap>~;
for(@files){
$text .= "<input type=\"hidden\" name=old_cmd value=\"$_\">";
}
$text .= qq~&nbsp;<input name="cmd" id="cmd" style="width:280px" value="$filename">
<input type="submit" value="$fm->{MESSAGES}->{ok}"  class="button">
<input type="button" value="$fm->{MESSAGES}->{cancel}" onclick="window.close()" class="button"></td></tr>
<tr><td><hr align="left" width="392px" class="line"></td>
<tr>
<td>&nbsp;<b>$fm->{MESSAGES}->{del_directory}:</b></td></tr>
</table>
<div>~;
$text .="<input name=\"folder\" type=\"radio\" onclick=\"tree.location.href='$fm->{SCRIPT}?action=tree';setPath2('');\" ".(!$fm->{isShared}? 'checked':'')." value=\"\">/";
for( keys %{ $fm->currentUser->{'SHARED'} } ){
#next unless -e $_;
$text .="<ul class=\"fm\"><li><label><input name=\"folder\" type=\"radio\" onclick=\"tree.location.href='$fm->{SCRIPT}?action=tree&amp;dir=(shared)$_';setPath2('');\" ".($fm->{isShared} eq $_? 'checked':'')." value=\"(shared)$_\"><img src=\"$fm->{htmlDataFolder}/sfolder.gif\" alt=\"\"> $_ </label>";
}
$text .=qq~</li></ul></div><table width="100%">
<tr><td><hr align="left" width="392px" class="line"></td>
<tr>
<td>
<iframe name="tree" frameborder="0" allowtransparency="true" style="width:385; border-style:none; height:298" src="$fm->{SCRIPT}?action=tree&amp;dir=~.($fm->{isShared}?'(shared)':'').qq~$fm->{isShared}"></iframe></td>
</tr>
</table>
</div>~;
$fm->asHtml(text=>$text, title=>$move? $fm->{MESSAGES}->{move}:$fm->{MESSAGES}->{copy_file});
}
sub move{
copy_f(1);
}
sub wanted {
(my $name = $File::Find::name)=~s/$fm->{HOME}//;
if (-d "$File::Find::name"){
File::Path::mkpath("$fm->{CMD}/$name", 0, 0755) unless -d "$fm->{CMD}/$name";
}
else{
File::Copy::copy("$File::Find::name", "$fm->{CMD}/$name");
}
}
sub tree{
$fm->{HOME}=$fm->getCurrentPath();
File::Find::find(\&build_tree, $fm->{HOME});
my $text=qq~
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>File list</title>
<link rel="stylesheet" type="text/css" href="$fm->{htmlDataFolder}/fm.css">
<script type="text/javascript" src="$fm->{htmlDataFolder}/fm.js"></script>
</head>
<body onload="pageLoad();">
<div id="tree" onmouseover="tMove(event, 1)" onmouseout ="tMove(event)" onclick="tClick(event)">~;
for my $cat (@{$fm->Tree->{''}}){
my $tmp =  treeline($cat->{id}, $fm->Tree);
my $coll = $tmp ? 'c':'l';
$text.=qq~<img src='$fm->{htmlDataFolder}/$coll.gif'><span class="fld" id="A$cat->{id}">$cat->{Title}</span><br>~;
$text.=qq~<div>$tmp</div>~ if $tmp;
}
$text.="<div>\n</body>\n</html>\n";
print "Content-type: text/html; charset=utf-8\n\n";
print $text;
exit;
}
sub build_tree{
my $name= $File::Find::name;
return if $name eq $fm->{HOME} or !-d $name or $name=~/\.thumb/;
$name=~s/\Q$fm->{HOME}\E//g;
$name=~s/^\///g;
if ($name!~m/\//){push @{$fm->Tree->{''}}, {id=>$name,Title=>$name};}
else{
$name=~m/(.*)\/([^\/]+)/;
push @{$fm->Tree->{$1}},{id=>$1."/".$2, Title=>$2};
}
}
sub treeline{
my $cat_id = shift;
my $Tree = shift;
return unless $cat_id;
my $content = '';
for my $subcat (@{$Tree->{$cat_id}}){
my $tmp = treeline($subcat->{id}, $Tree);
my $coll = $tmp? "c":"l";
$content .= qq~<img src='$fm->{htmlDataFolder}/$coll.gif'><span class="fld" id="A$subcat->{id}">$subcat->{Title}</span><br>~;
$content .= $tmp ? "<div>\n$tmp</div>":"";
}
return $content;
}
sub findfile{
print "Content-type: text/html; charset=utf-8\n\n";
print qq~
<html>
<head><head><title>$fm->{MESSAGES}->{search}</title>
<link rel="stylesheet" type="text/css" href="$fm->{htmlDataFolder}/fm.css">
<script type="text/javascript">
function _Search(){
opener.document.mode.search.value=document.mode.search.value;
if (document.mode.matchCase.checked) opener.document.mode.matchCase.checked=true;
else opener.document.mode.matchCase.checked=false;
if (document.mode.inNotes.checked) opener.document.mode.inNotes.checked=true;
else opener.document.mode.inNotes.checked=false;
opener.document.mode.dir.value = "";
opener.document.mode.submit();
window.close();
return false;
}
</script>
</head>
<body topmargin=0 leftmargin=0>
<br><center>
<form name=mode onsubmit="return _Search()">
<p><b>$fm->{MESSAGES}->{search}:
<input type=text name=search size=20 value="$fm->{CGI}->{search}">
<input type=submit value=go> <br>
<input type=checkbox name=matchCase value=1 matchCase> $fm->{MESSAGES}->{match_case}
<input type=checkbox name=inNotes value=1 ~. ($fm->{CGI}->{inNotes}? 'checked':'') .qq~> $fm->{MESSAGES}->{notes}
</b></p>
~;
exit;
}
sub upload2{
print "Content-type: text/html; charset=utf-8\n\n";
if($fm->{CGI}->{file}){
error ($fm->{MESSAGES}->{over_quota}) unless $fm->currentfreeSpace($ENV{CONTENT_LENGTH});
}
my $dir = $fm->getCurrentPath($fm->{CGI}->{dir},'u');
my @fDesc = CGI::param('fileDescription') if $fm->{fileDescriptionOn};
my @descLine; my @uploaded;
for (@fDesc){
$_ =~ s/<!--(.|\n)*-->//g;
$_ =~ s/<([^>]|\n)*>//g;
push @descLine,$_ if $_;
}
my ($s,$ind) = (0,0);
my @files = CGI::param('file');
for(@files){
next unless $_;
error("A File Name $_ or Description cannot contain any of the following illegal characters:  * ? <> | : & ! ; [ ] ^ + @ ' \~ { }  $ ! % ( )", 2)
if $_=~m/[*?<>|:&!;[]^+@'\~{}$!%()]/;
error("$fm->{MESSAGES}->{err_upl_disabled}!") if !$fm->allowFile(lc $_);
if (CGI::param('overwrite') && -e "$dir/$_"){
print "<html><script language='JavaScript' type='text/javascript'>alert('A File with the same name already exists! \\nThe original file has been retained.')</script></html>\n";
}
else {

my $filename=$fm->saveFile($_, $dir, $fm->{CGI}->{mode});
push @uploaded, $filename;
$fm->addNote("$dir/$filename", $fDesc[$ind]);
$ind++;
$fm->logger("File '$filename' uploaded to '".$fm->getUserPath($fm->{CGI}->{dir})."'");
}
}
my $content=1;
my ($descriptionString,$uploadInfo);
my $time = localtime;
if($ind && $fm->{sendConfirmUpload}){
my $message="$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:\n ". join ",\n",@uploaded;
if($fm->{sendAsHtml}){
$message = $fm->get_record( $fm->read_file($fm->{templateDir}."/".$fm->{emlFileUpload}),
{
MESSAGE=>$message,
login=>$fm->currentUser->{login},
first=>$fm->currentUser->{first},
last=>$fm->currentUser->{last},
files=>join ('<br>',@uploaded),
descriptions=>join('<br>' ,@descLine),
upload_to=>$fm->getAdminPath($fm->{CGI}->{dir}),
}
);
}
$fm->male($fm->{toAdmin}, $fm->{fromAdmin}, "$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:", $message);
if ($fm->{currentUser}->{currentShared}){
if ($fm->{currentUser}->{currentShared}->{groupemail} && $fm->{currentUser}->{currentShared}->{groupemail} ne $fm->{currentUser}->{email}){
        $fm->male($fm->{currentUser}->{currentShared}->{groupemail}, $fm->{fromAdmin}, "$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:", $message);
}
if ($fm->{sendToGroupUser}){
$fm->sendToGroup(
group=>$fm->{currentUser}->{currentShared}->{groupId},
message=>$message,
subject=>"$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:",
);
}
}
else{$fm->sendToFolderOwner($dir,$message);}
}
my $banned = $fm->currentDisabled;
my $bannedFile;
if (ref $banned eq 'HASH'){
my @ban = keys %$banned;
for (@ban){$_="'$_'";}
$bannedFile = join(',', @ban);
}
$bannedFile = "bannedFile =new Array($bannedFile);";
print qq~
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>$fm->{MESSAGES}->{upload_file_to} $dir</title>
<link rel="stylesheet" type="text/css" href="$fm->{htmlDataFolder}/fm.css">
<script type="text/javascript" src="$fm->{htmlDataFolder}/fm.js"></script>
<script src="$fm->{htmlDataFolder}/css_browser_selector.js" type="text/javascript"></script>~;
print qq~<script type="text/javascript">
$bannedFile
function checkFile(fileform){
~;
print qq~
for(var a=0; a<bannedFile.length; a++){
if(fileform.value.indexOf("."+bannedFile[a])>=0) {
alert("$fm->{MESSAGES}->{err_banned_format}");
fileform.value='';
fileform.focus();
return;
}
}
~;
my $regExp = '\*|\?|\<|\>|\||\&|\!|\;|\[|\]|\^|\+|\@|\'|\~|\{|\}|\!|\%|\(|\)';
print qq~var re5digit=/$regExp/; //regular expression
if (re5digit.test(fileform.value)){
alert ("$fm->{MESSAGES}->{cannot_contain}:\\n  * ? <> | & ! ; [ ] ^ + @ ' \~ { } ! % ( ) '");
javascript:document.forms[0].reset();
fileform.value="";
fileform.focus();
return;
}
}
</script> ~ ;
my $onchange=qq~ onchange="checkFile(this)"~;
print qq~</head>
<body ~;
if($ind){
my $text ="$ind file";
$text ="s" if $ind>1;
$text =" saved in $fm->{CGI}->{dir}\n";
print " onload=go()>",$text;
print "</body></html>";
exit;
}
my $fileDesc=qq~<tr><td>$fm->{MESSAGES}->{description}:</td>
<td><input type="text" name="fileDescription" size="34" style="width:250pt" maxlength="32"><td></tr>~ if $fm->{fileDescriptionOn};
print qq~>
<div id="loadI" style="position:absolute;z-index:4; top:176; left:100; visibility:hidden;">
<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="https://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0" width="259" height="130" id="Untitled-1" align="middle">
<param name="allowScriptAccess" value="sameDomain">
<param name="movie" value="$fm->{htmlDataFolder}/Uploading.swf">
<param name="quality" value="high"><param name="bgcolor" value="#ffffff">
<embed src="$fm->{htmlDataFolder}/Uploading.swf" quality="high" bgcolor="#ffffff" width="259" height="130" name="Untitled-1" align="middle" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="https://www.macromedia.com/go/getflashplayer">
</object>
</div>
<div id="upload2" style="position:absolute;z-index:1;visibility:visible; top:15px;width:460px;height:105px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UploadIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UploadIcon}) !important;background:none;"></span></td>
<td class="subheader">$fm->{MESSAGES}->{upload}</td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="452px" class="line"></td>
</tr>
</table>
<table>
<tr>
<td><a class="uploadtab" href="$script?action=upload&amp;dir=$fm->{CGI}->{dir}" style="margin-left: 4px"><span>$fm->{MESSAGES}->{upload}</span></a>
<td><a class="uploadtab" href="$script?action=uploadfl&amp;dir=$fm->{CGI}->{dir}" style="margin-left: 0px"><span>Flash $fm->{MESSAGES}->{upload}</span></a></td>
<!-- <td><a class="uploadtab" href="$script?action=uploadja&amp;dir=$dir" style="margin-left: 0px"><span>Java $fm->{MESSAGES}->{upload}</span></a></td>-->
</tr>
</table>
<table width="100%">
<tr>
<td><hr class="uploadline"></td>
</tr>
</table>
<form method="post" action="$fm->{SCRIPT}"  ENCTYPE=\"multipart/form-data\" onsubmit="load();">
<input type="hidden" name="mode" value="$fm->{CGI}->{mode}">
<input type="hidden" name="action" value="upload">
<input type="hidden" name="dir" value="$fm->{CGI}->{dir}">
<table width="100%" style="margin-left: 7px">
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type="file" name="file" size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type="file" name="file" size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type="file" name="file" size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type="file" name="file" size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type="file" name="file" size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type="file" name="file" size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type="file" name="file" size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type="file" name="file" size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type="file" name="file" size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type="file" name="file" size="34" $onchange><td></tr>$fileDesc
<tr><td colspan="2"><input type="checkbox" name="overwrite" value="1" checked> Prevent files from being overwritten</td></tr>
<tr><td colspan="2" align="center"><input type="submit" value="$fm->{MESSAGES}->{upload_files}">
<input type="reset" onclick="window.close()" value="$fm->{MESSAGES}->{cancel}">
</td></tr></table></form>
</div>~;
print "</body></html>";
exit;
}
sub uplja{
print "Content-type: text/html;  charset=utf-8\n\n";
$fm->currentUser($fm->{CGI}->{user});
if ($fm->{CGI}->{cip} eq  Digest::MD5::md5_hex($fm->{CGI}->{user}.$fm->{secretWord}) ){
unless ($fm->currentfreeSpace($ENV{CONTENT_LENGTH})){
die  "Can't upload files\n";
}
my $base_directory = $fm->getCurrentPath($fm->{CGI}->{dir});
my $query = new CGI;
my @files;
$fm->logger("test - $base_directory");
foreach my $ptmp ($query->param){
next if $ptmp !~ /userfile/;
my @tmps = $query->param($ptmp);
my @infiles = $query->upload($ptmp);
my $i = 0;
foreach my $tmp (@tmps){
my $infile = $tmps[$i++];
$tmp =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$tmp =~ s/\+/ /sg;
$tmp =~ s/\\/\//g;
$tmp =~ s/^\/(.+)$/$1/g;
$tmp =~ s/\.\././g;
if ($tmp=~m/[\*\?\|:;\{\}<>\@\#~]/){
next;
}
unless ($fm->currentRights->{'u'} && $fm->allowFile($tmp)){
next;
}
my $filename = $base_directory.'/'. $tmp;
my $dir = $filename;
$dir =~ s/^(.+\/)[^\/]+$/$1/;
my @dirs = split('/', $dir);
my $cur = '';
foreach my $d (@dirs)
{
$cur = $cur . $d . '/';
if ($cur !~ /\/[^\/]+/)
{
next;
}
mkdir $cur;
if ($! ne '' && $! ne 'File exists')
{
print "could not make dir $cur"; # premature header error
exit;
}
}
open FILE, ">$filename" or die "Can't open file $filename";
binmode FILE;
binmode $infile;
while (<$infile>)
{
print FILE $_;
}
close FILE;
close $infile;
$fm->logger("File '$filename' uploaded to '".$fm->getUserPath($fm->{CGI}->{dir})."'");
push @files, $tmp;
}
}
if(@files && $fm->{sendConfirmUpload}){
my $message="$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:\n ". join ",\n",@files;
if($fm->{sendAsHtml}){
$fm->getMessages( $fm->{currentUser}->{language}  || 'en');
$message = $fm->get_record( $fm->read_file($fm->{templateDir}."/".$fm->{emlFileUpload}),
{
MESSAGE=>$message,
login=>$fm->currentUser->{login},
first=>$fm->currentUser->{first},
last=>$fm->currentUser->{last},
files=>join ('<br>',@files),
upload_to=>$fm->getAdminPath($fm->{CGI}->{dir}),
}
);
}
$fm->male($fm->{toAdmin}, $fm->{fromAdmin}, "$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:", $message);
if ($fm->{currentUser}->{currentShared}){
if ($fm->{currentUser}->{currentShared}->{groupemail} && $fm->{currentUser}->{currentShared}->{groupemail} ne $fm->{currentUser}->{email}){
$fm->male($fm->{currentUser}->{currentShared}->{groupemail}, $fm->{fromAdmin}, "$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:", $message);
}
if ($fm->{sendToGroupUser}){
$fm->sendToGroup(
group=>$fm->{currentUser}->{currentShared}->{groupId},
message=>$message,
subject=>"$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:",
);
}
}
else{$fm->sendToFolderOwner($dir,$message);}
}
}
else{die "Can't upload file\n";}
exit;
}
sub uploadja{
$dir = URI::Escape::uri_escape(encode("UTF-8",$dir));
print "Content-Type: text/html;  charset=utf-8\n\n";
my $md5 = Digest::MD5::md5_hex($fm->currentUser->{login}.$fm->{secretWord});
print qq~
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<head>
<title>$fm->{MESSAGES}->{upload}</title>
<link rel="stylesheet" type="text/css" href="$fm->{htmlDataFolder}/fm.css">
<script type="text/javascript" src="$fm->{htmlDataFolder}/FlashObject.js"></script>
<script src="$fm->{htmlDataFolder}/css_browser_selector.js" type="text/javascript"></script>
</head>
<div id="uploadjava" style="position:absolute;z-index:1;visibility:visible; top:15px;width:460px;height:105px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UploadIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UploadIcon}) !important;background:none;"></span></td>
<td class="subheader">$fm->{MESSAGES}->{upload}</td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="452px" class="line"></td>
</tr>
</table>
<table>
<tr>
<td><a class="uploadtab" href="$script?action=upload&amp;dir=$dir" style="margin-left: 4px"><span>$fm->{MESSAGES}->{upload}</span></a>
<td><a class="uploadtab" href="$script?action=uploadfl&amp;dir=$dir" style="margin-left: 0px"><span>Flash $fm->{MESSAGES}->{upload}</span></a></td>
<!-- <td><a class="uploadtab" href="$script?action=uploadja&amp;dir=$dir" style="margin-left: 0px"><span>Java $fm->{MESSAGES}->{upload}</span></a></td>-->
</tr>
</table>
<table width="100%">
<tr>
<td><hr class="uploadline"></td>
</tr>
</table>
<div id="uploadjavaconent" style="position:absolute;z-index:2;visibility:visible; left:6px;top:118px;width:460px;height:560px;">
<applet name="uploadApplet" code="javaatwork.myuploader.UploadApplet.class" archive="$fm->{htmlDataFolder}/myuploader/myuploader-free-signed-v1101.jar, $fm->{htmlDataFolder}/myuploader/labels.jar" width="410"  height="509">
<param name="uploadURL" value="$script?action=uplja&amp;dir=$dir&amp;cip=$md5&amp;user=~.$fm->currentUser->{login}.qq~">
<param name="successURL" value="$script?action=uploadok">
<param name="backgroundColor" value="#D8D8D8">
<param name="showThumbNailsInApplet" value="true">
</applet>
</div>
</div>
</body>
</html>
~;
exit;
}
sub uploadok{
print "Content-Type: text/html;  charset=utf-8\n\n";
print qq~<html>
<head>
</head>
<body onload=\"parent.opener.location.reload();window.close()\">
<b>Upload Process finished!</b>
</body></html>
~;
exit;
}
sub uploadfl{
        print "Content-Type: text/html;  charset=utf-8\n\n";
        my $url = $fm->{sslUri}? $fm->{sslUri} : $ENV{SCRIPT_NAME};
        my $md5 = Digest::MD5::md5_hex($fm->currentUser->{login}.$fm->{secretWord});
        print qq~<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>$fm->{MESSAGES}->{upload}</title>
        <link rel="stylesheet" type="text/css" href="$fm->{htmlDataFolder}/fm.css">
        <script type="text/javascript" src="$fm->{htmlDataFolder}/FlashObject.js"></script>
        <script src="$fm->{htmlDataFolder}/css_browser_selector.js" type="text/javascript"></script>
        </head>
        <div id="uploadflu" style="position:absolute;z-index:1;visibility:visible; top:15px;width:460px;height:105px;">
        <table>
        <tr>
        <td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UploadIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UploadIcon}) !important;background:none;"></span></td>
        <td class="subheader">$fm->{MESSAGES}->{upload}</td>
        </tr>
        </table>
        <table width="100%">
        <tr>
        <td><hr width="452px" class="line"></td>
        </tr>
        </table>
        <table>
        <tr>
        <td><a class="uploadtab" href="$script?action=upload&amp;dir=$dir" style="margin-left: 4px"><span>$fm->{MESSAGES}->{upload}</span></a>
        <td><a class="uploadtab" href="$script?action=uploadfl&amp;dir=$dir" style="margin-left: 0px"><span>Flash $fm->{MESSAGES}->{upload}</span></a></td>
        <!-- <td><a class="uploadtab" href="$script?action=uploadja&amp;dir=$dir" style="margin-left: 0px"><span>Java $fm->{MESSAGES}->{upload}</span></a></td> -->
        </tr>
        </table>
        <table width="100%">
        <tr>
        <td><hr class="uploadline"></td>
        </tr>
        </table>
        <div  id="flashcontent" style="position:absolute;z-index:2;visibility:visible; left:7px;top:98px;width:460px;height:560px;">
        </div>
        <script type="text/javascript">
        <!--
        var flashObj = new FlashObject("$fm->{htmlDataFolder}/fileUpload.swf", "uploadFile", "100%", "100%", "8.0.5", "#eeeeee", true);
        flashObj.addVariable ("uploadUrl", "$url");
        flashObj.addParam("wmode", "transparent");
        flashObj.addVariable ("maxFileSize", "1048576");
        flashObj.addVariable ("folderName", "$fm->{CGI}->{dir}");
        flashObj.addVariable ("uploadMode", "$fm->{CGI}->{mode}");
        flashObj.addVariable ("userLogin", "$fm->{currentUser}->{login}");
        flashObj.addVariable ("uploadButtonlabel", "$fm->{MESSAGES}->{upload}");
        flashObj.addVariable ("clearButtonlabel", "$fm->{MESSAGES}->{cancel}");
        flashObj.addVariable ("clearButtonlabel", "$fm->{MESSAGES}->{cancel}");
        flashObj.addVariable ("no_right", "$fm->{MESSAGES}->{no_right}");
        flashObj.addVariable ("over_quota", "$fm->{MESSAGES}->{over_quota}");
        flashObj.addVariable ("err_banned_format", "$fm->{MESSAGES}->{err_banned_format}");
        flashObj.addVariable ("cannot_contain", "$fm->{MESSAGES}->{cannot_contain}");
        flashObj.addVariable ("uploadcomplete", "$fm->{MESSAGES}->{uploadcomplete}");
        flashObj.addVariable ("md5", "$md5");
        flashObj.write("flashcontent");
        // -->
        </script>
        </div>
        </body>
        </html>
        ~;
        exit;
}
sub flu{
        for (keys %{$fm->{CGI}}){
                (my $tmp=$_)=~s/amp;//;
                $fm->{CGI}->{$tmp}=$fm->{CGI}->{$_};
        }





        if ($fm->{CGI}->{cip} eq  Digest::MD5::md5_hex($fm->{CGI}->{user}.$fm->{secretWord}) ){
                $fm->currentUser($fm->{CGI}->{user});
                my $folder=$fm->getCurrentPath($fm->{CGI}->{dir},'u');
                unless ($fm->currentfreeSpace($ENV{CONTENT_LENGTH})){
                        print "Status: 503\n\n";
                        exit;
                }
                my $file=$fm->{CGI}->{'Filedata'};

                if (!$fm->allowFile(lc $file)){
                                print "Status: 501\n\n";
                                exit;
                }

                if ($file=~m/[\*\?<>\|\:\&;\^\@\'\~\{\}\!\%\(\)]/){
                        print "Status: 504\n\n";
                        exit;
                }
        unless ($folder){
                        print "Status: 502\n\n";
                        exit;
                }
        $fm->saveFile($file, $folder, $fm->{CGI}->{mode});
        if ($fm->{sendConfirmFlashUpload}){
        my $message="$folder/$file uploaded via flash mode";
        if($fm->{sendAsHtml}){
                $fm->getMessages( $fm->{currentUser}->{language}  || 'en');
                $message = $fm->get_record( $fm->read_file($fm->{templateDir}."/".$fm->{emlFileUpload}),
        {
                MESSAGE=>$message,
                login=>$fm->currentUser->{login},
                                first=>$fm->currentUser->{first},
                                last=>$fm->currentUser->{last},
                files=>join ('<br>',$file),
                upload_to=>$fm->getAdminPath($fm->{CGI}->{dir}),
        }
        );
        }
        $fm->male($fm->{toAdmin}, $fm->{fromAdmin}, "$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:", $message);
        if ($fm->{currentUser}->{currentShared}){
        if ($fm->{currentUser}->{currentShared}->{groupemail} && $fm->{currentUser}->{currentShared}->{groupemail} ne $fm->{currentUser}->{email}){
        $fm->male($fm->{currentUser}->{currentShared}->{groupemail}, $fm->{fromAdmin}, "$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:", $message);
        }
        if ($fm->{sendToGroupUser}){
        $fm->sendToGroup(
        group=>$fm->{currentUser}->{currentShared}->{groupId},
        message=>$message,
        subject=>"$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:",
        );
        }
        }
        else{$fm->sendToFolderOwner($dir,$message);}
        }
        print "Content-type: text/html\n\n";
        print qq~<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
        <html><head><title> Upload Page </title></head>
        <body><h3>Upload Successful</h3></body>
        </html>
        ~;
        $fm->logger("File '$file' uploaded to '".$fm->getUserPath($fm->{CGI}->{dir})."'");
        }
        else{
        print "Status: 501\n\n";
        exit;
        }
        exit;
}

sub uploadX{
print "Content-Type: text/html;  charset=utf-8\n\n";
print qq~
<iframe src="javascript:false;" name="xupload" style="position:absolute;left:-9999px;"></iframe>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>$fm->{MESSAGES}->{upload}</title>
<link rel="STYLESHEET" type="text/css" href="$fm->{htmlDataFolder}/fm.css">
<script src="$fm->{htmlDataFolder}/fm_bar.js" type="text/javascript"></script>
<script src="$fm->{htmlDataFolder}/css_browser_selector.js" type="text/javascript"></script>
<script type="text/javascript">
</script>
</head>
<body>
<div id="upload" style="position:absolute;z-index:1;visibility:visible; top:15px;width:460px;height:105px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UploadIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UploadIcon}) !important;background:none;"></span></td>
<td class="subheader">$fm->{MESSAGES}->{upload}</td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="452px" class="line"></td>
</tr>
</table>
<table>
<tr>
<td><a class="uploadtab" href="$script?action=upload&amp;dir=$dir" style="margin-left: 4px"><span>$fm->{MESSAGES}->{upload}</span></a>
<td><a class="uploadtab" href="$script?action=uploadfl&amp;dir=$dir" style="margin-left: 0px"><span>Flash $fm->{MESSAGES}->{upload}</span></a></td>
<!-- <td><a class="uploadtab" href="$script?action=uploadja&amp;dir=$dir" style="margin-left: 0px"><span>Java $fm->{MESSAGES}->{upload}</span></a></td>-->
</tr>
</table>
<table width="100%">
<tr>
<td><hr class="uploadline"></td>
</tr>
</table>
<div id="uploadx" style="position:absolute;z-index:2;visibility:visible; left:7px;top:120px;width:448px;height:540px;">
<form id="myform" enctype="multipart/form-data" action="/cgi-bin/xupload/upload.cgi" method="post" onSubmit="return StartUpload(this);">
<input type="hidden" name="dir" value="$fm->{CGI}->{dir}">
<div><div><div>$fm->{MESSAGES}->{file}: <input id="my_file_element" type="file" name="file_1" size=58></div>
<div id="files_list"></div>
<Input type="hidden" name="pbmode" value="3">
<p align=center>
<input type=submit value="$fm->{MESSAGES}->{upload_files}" id="submit_btn">
<input type=reset onclick="window.close()" value=$fm->{MESSAGES}->{cancel}>
</p>
</DIV>
</form>
</Center>
<script type="text/javascript">
//Specify your form ID
var x_form_id = 'myform';
var x_mode = 1;
var x_tmpl_name = '';
</script>
<script src="/xupload/xupload.js" type="text/javascript"></script>
</div>
</div>
</body>
</html>~;
exit;
}
sub upload{
#error_right('u') unless $Rights->{'u'};
print "Content-Type: text/html;  charset=utf-8\n\n";
my $dir = $fm->{CGI}->{dir};
if ($fm->{CGI}->{session}){
use Fcntl qw(:DEFAULT :flock);
my ($bufferSize, $buffer, $bytesRead) = (1024*8,0,0);
$fm->{tmpDir} = "./status";
mkdir "$fm->{tmpDir}",0755  unless -d $fm->{tmpDir} or die "Can't create tmp folder $fm->{tmpDir} $!!";
my $startTime=time;
unless (-f "$fm->{tmpDir}/$fm->{CGI}->{session}"){
        open (ST , ">$fm->{tmpDir}/$fm->{CGI}->{session}") or error("Can't open status file $!");
        flock(ST, LOCK_EX);
        print ST "$ENV{'CONTENT_LENGTH'} 0 $startTime\n";
        close ST;
}
#create template file for content
open (TMP , ">$fm->{tmpDir}/$fm->{CGI}->{session}.tmp") or error("Can't open tmp session file $!", '1', $fm->{CGI}->{session});
binmode TMP;
flock(TMP, LOCK_EX);
my $bytesRead;
while (read(STDIN, my $buffer,$bufferSize)){
$bytesRead+=length $buffer;
print TMP $buffer;
my $proz = int($bytesRead/$ENV{'CONTENT_LENGTH'} *100);
$proz = 99 if $proz>=100;
open (ST , ">$fm->{tmpDir}/$fm->{CGI}->{session}");
flock(ST, LOCK_EX);
print ST "$ENV{'CONTENT_LENGTH'} $proz $startTime\n";
close ST;
select(undef, undef, undef, 0.002);
}
close TMP;
#upload finished
open (ST , ">$fm->{tmpDir}/$fm->{CGI}->{session}");
flock(ST, LOCK_EX);
print ST "$ENV{'CONTENT_LENGTH'} 100 $startTime\n";
close ST;
open(STDIN,"$fm->{tmpDir}/$fm->{CGI}->{session}.tmp") or error("Can't open temp file $fm->{CGI}->{session}.tmp $!", '1', $fm->{CGI}->{session});
use CGI;
for(CGI::param()){$fm->{CGI}->{$_}=CGI::param($_);}
#protect from access over main root folder
$fm->{CGI}->{dir} =~ s/\.\.\///g;
$dir = $fm->getCurrentPath($fm->{CGI}->{dir},'u');
my @fDesc = CGI::param('fileDescription') if $fm->{fileDescriptionOn};
#protect html
my @descLine;
for (@fDesc){
$_ =~ s/<!--(.|\n)*-->//g;
$_ =~ s/<([^>]|\n)*>//g;
push @descLine,$_ if $_;
}
my $descriptionString;
my $ind=0;
my $time=localtime;
my $uploadInfo = '';
my @files;
for(CGI::param('file')){
unless ($_){$ind++; next;}
(my $fn = $_) =~s/^.*([^\/\\]+)$/$1/;
if ($fn=~m/[\*\?<>\|:&;\[\]\^\+\@\'\~\{\}\$%\(\)]/){$ind++; error("A File Name $_ or Description cannot contain any of the following illegal characters:  * ? <> | : & ! ; [ ] ^ + @ ' \~ { }  $ ! % ( )", 2); next;}
if (!$fm->allowFile(lc $fn)){$ind++; error("$fm->{MESSAGES}->{err_upl_disabled}!"); next;}
unless ($fm->allowFile($fn)){$ind++; next;}
if (CGI::param('overwrite') && -e "$dir/$_"){
print "Content-type: text/html\n\n";
print "<html><script language='JavaScript' type='text/javascript'>alert('A File with the same name already exists! \\nThe original file has been retained.')</script></html>\n";
}
else {
my $filename=$fm->saveFile($_, $dir, $fm->{CGI}->{mode});
$fm->addNote("$dir/$filename", $fDesc[$ind]);
$ind++;
$fm->logger("File '$filename' uploaded to '".$fm->getUserPath($fm->{CGI}->{dir})."'");
push @files, $filename;
}
if($ind && $fm->{sendConfirmUpload}){
my $message="$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:\n ". join ",\n",@files;
if($fm->{sendAsHtml}){
$message = $fm->get_record( $fm->read_file($fm->{templateDir}."/".$fm->{emlFileUpload}),
{
MESSAGE=>$message,
login=>$fm->currentUser->{login},
first=>$fm->currentUser->{first},
last=>$fm->currentUser->{last},
files=>join ('<br> ',@files),
descriptions=>join('<br>' ,@descLine),
upload_to=>$fm->getAdminPath($fm->{CGI}->{dir}),
}
);
}
$fm->male($fm->{toAdmin}, $fm->{fromAdmin}, "$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:", $message);
if ($fm->{currentUser}->{currentShared}){
if ($fm->{currentUser}->{currentShared}->{groupemail} && $fm->{currentUser}->{currentShared}->{groupemail} ne $fm->{currentUser}->{email}){
$fm->male($fm->{currentUser}->{currentShared}->{groupemail}, $fm->{fromAdmin}, "$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:", $message);
}
if ($fm->{sendToGroupUser}){
$fm->sendToGroup(
group=>$fm->{currentUser}->{currentShared}->{groupId},
message=>$message,
subject=>"$fm->{MESSAGES}->{re} $fm->{currentUser}->{login} $fm->{MESSAGES}->{successfully_uploaded}:",
);
}
}
else{$fm->sendToFolderOwner($dir,$message);}
}
}
close STDIN;
unlink "$fm->{tmpDir}/$fm->{CGI}->{session}.tmp" or die $!;
print qq~
<html>
<head>
</head>
<body onload=\"parent.opener.location.reload(); parent.CloseUpload('$fm->{CGI}->{session}');\">
<b>Upload Process finished!</b>
</body></html>
~;
unlink "$fm->{tmpDir}/$fm->{CGI}->{session}.tmp";
#unlink "$fm->{tmpDir}/$fm->{CGI}->{session}";
exit;
}
my $banned = $fm->currentDisabled;
my $bannedFile;
if (ref $banned eq 'HASH'){
my @ban = keys %$banned;
for (@ban){$_="'$_'";}
$bannedFile = join(',', @ban);
}
$bannedFile = "bannedFile =new Array($bannedFile);";
my $onchange=qq~ onchange="checkFile(this)"~;
print qq~
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>$fm->{MESSAGES}->{upload}</title>
<link rel="STYLESHEET" type="text/css" href="$fm->{htmlDataFolder}/fm.css">
<script src="$fm->{htmlDataFolder}/fm_bar.js" type="text/javascript"></script>
<script src="$fm->{htmlDataFolder}/css_browser_selector.js" type="text/javascript"></script>
<script type="text/javascript">
$bannedFile
function checkFile(fileform){
for(var a=0; a<bannedFile.length; a++){
if(fileform.value.indexOf("."+bannedFile[a])>=0) {
alert("$fm->{MESSAGES}->{err_banned_format}");
fileform.focus();
return;
}
}
}
</script>
</head>
<body>
<div id="statusWnd" style="position:absolute;z-index:4; width:259; height:130; top:176; left:100; display:none; border-style: solid; border-width:1; border-color:#686868; background-image:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{MainBackground})">
<center>
<div id="statusLine" style="position:relative; width:200; height:20; top:20; border-style: solid; border-width:1; border-color:#686868; background-color:#FFFFFF">
<div id="statusBar" style="float: left; position:relative; width:0%; height:20; top:0; border-style: none; border-width:1; border-color:#333333; background-image:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{Progressbar})"></div>
</div>
<div id="statusInfo" style="position:relative; width:200; top:50">
</div>
</center>
</div>
<iframe style="visibility:hidden; width:0px; height:0px; overflow:hidden;border:10" src="$fm->{htmlTemplateFolder}/secure.html" name="contrFrame"></iframe>
~;
my $fileDesc=qq~<tr><td>$fm->{MESSAGES}->{description}:</td><td><input type=text name=fileDescription size="34" style="width:250pt" maxlength="32"><td></tr>~ if $fm->{fileDescriptionOn};
print qq~
<div id="upload" style="position:absolute;z-index:1;visibility:visible; top:15px;width:460px;height:105px;">
<table>
<tr>
<td><span style="filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UploadIcon},sizingMethod=image);display:block;height:$fm->{IconHeight};width:$fm->{IconWidth};background:url($fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/$fm->{UploadIcon}) !important;background:none;"></span></td>
<td class="subheader">$fm->{MESSAGES}->{upload}</td>
</tr>
</table>
<table width="100%">
<tr>
<td><hr width="452px" class="line"></td>
</tr>
</table>
<table>
<tr>
<td><a class="uploadtab" href="$script?action=upload&amp;dir=$dir" style="margin-left: 4px"><span>$fm->{MESSAGES}->{upload}</span></a>
<td><a class="uploadtab" href="$script?action=uploadfl&amp;dir=$dir" style="margin-left: 0px"><span>Flash $fm->{MESSAGES}->{upload}</span></a></td>
<!-- <td><a class="uploadtab" href="$script?action=uploadja&amp;dir=$dir" style="margin-left: 0px"><span>Java $fm->{MESSAGES}->{upload}</span></a></td>-->
</tr>
</table>
<table width="100%">
<tr>
<td><hr class="uploadline"></td>
</tr>
</table>
<form onsubmit="return startUp();"  target="contrFrame" name="myform" method=post action="$fm->{SCRIPT}?action=upload"  ENCTYPE=\"multipart/form-data\">
<input type="hidden" name="mode" value="$fm->{CGI}->{mode}">
<input type="hidden" name="shared" value="$fm->{CGI}->{shared}">
<input type="hidden" name="dir" value="$dir">
<table width="100%" style="margin-left: 7px">
<tr><td >$fm->{MESSAGES}->{file}:</td><td><input type=file name=file size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type=file name=file size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type=file name=file size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type=file name=file size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type=file name=file size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type=file name=file size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type=file name=file size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type=file name=file size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type=file name=file size="34" $onchange><td></tr>$fileDesc
<tr><td>$fm->{MESSAGES}->{file}:</td><td><input type=file name=file size="34" $onchange><td></tr>$fileDesc
<tr><td colspan="2"><input type="checkbox" name="overwrite" value="1" checked> Prevent files from being overwritten</td></tr>
<tr><td colspan=2 align=center><input type=submit value="$fm->{MESSAGES}->{upload_files}" name="btnSubmit">
<input type=reset onclick="window.close()" value=$fm->{MESSAGES}->{cancel}>
</td></tr></table></form></div></body></html>~;
exit;
}
sub forgott{
$fm->restore();exit;
}
sub restore{
$fm->restore();exit;
}
sub qbar{
return if $fm->{currentUser}->{isAdmin} && !$fm->{isShared};
my $quota = $fm->{isShared}? $fm->currentUser->{'SHARED'}->{$fm->{isShared}}->{slimit} : $fm->currentUser->{diskquota};
return unless $quota;
my $bar ='';
if ($fm->{quoteBarOn}){
        my $used = $fm->usedSpace($fm->{isShared}? $fm->currentUser->{'SHARED'}->{$fm->{isShared}}->{path} : undef);
        my $len = int (($used/1024) * 200/$quota);
        $len = 200 if $used/1024>$quota;
        $used = sprintf('%0.2F',$used/1024)." $fm->{MESSAGES}->{Mb}";
        my $quote = "$quota $fm->{MESSAGES}->{Mb}";
        $bar ="</td><td width=\"250\"><table><tr><td nowrap class=\"misc_header\"> | $fm->{MESSAGES}->{Space}: $used</td><td><div class=\"qbar\"><img src=\"$fm->{htmlDataFolder}/Skins/$fm->{SkinFolder}/qbar.gif\" style=\"height:9px;width:".$len."px;\"></div></td><td nowrap class=\"misc_header\">$quote</td></tr></table></td>";
}
return $bar;
}
sub play{
my $link = shift;
my $name = shift;
print "Content-type: text/html; charset=utf-8\n\n";
print  <<END;
<html>
<head>
<script type="text/javascript" src="$fm->{htmlDataFolder}/play/jquery.min.js"></script>
<script type="text/javascript" src="$fm->{htmlDataFolder}/play/jquery.jplayer.js"></script>
<script>
\$(document).ready(function(){
\$("#jquery_jplayer").jPlayer({
ready: function () {
\$(this).setFile("$link").play();
},
cssPrefix: "different_prefix_example",
volume: 50,
oggSupport: false,
swfPath:'$fm->{htmlDataFolder}/play'
})
.jPlayerId("play", "player_play")
.jPlayerId("pause", "player_pause")
.jPlayerId("stop", "player_stop")
.jPlayerId("loadBar", "player_progress_load_bar")
.jPlayerId("playBar", "player_progress_play_bar")
.jPlayerId("volumeMin", "player_volume_min")
.jPlayerId("volumeMax", "player_volume_max")
.jPlayerId("volumeBar", "player_volume_bar")
.jPlayerId("volumeBarValue", "player_volume_bar_value")
.onProgressChange( function(loadPercent, playedPercentRelative, playedPercentAbsolute, playedTime, totalTime) {
var myPlayedTime = new Date(playedTime);
var ptMin = (myPlayedTime.getUTCMinutes() < 10) ? "0" + myPlayedTime.getUTCMinutes() : myPlayedTime.getUTCMinutes();
var ptSec = (myPlayedTime.getUTCSeconds() < 10) ? "0" + myPlayedTime.getUTCSeconds() : myPlayedTime.getUTCSeconds();
\$("#play_time").text(ptMin+":"+ptSec);
var myTotalTime = new Date(totalTime);
var ttMin = (myTotalTime.getUTCMinutes() < 10) ? "0" + myTotalTime.getUTCMinutes() : myTotalTime.getUTCMinutes();
var ttSec = (myTotalTime.getUTCSeconds() < 10) ? "0" + myTotalTime.getUTCSeconds() : myTotalTime.getUTCSeconds();
\$("#total_time").text(ttMin+":"+ttSec);
})
.onSoundComplete( function() {
\$(this).play();
});
});
</script>
</head>
<body>
<style>
<!--
#player_container {
position: relative;
background-color:#eee;
width:426px;
height:150px;
border:1px solid #009be3;
}
#player_container  ul#player_controls {
list-style-type:none;
padding:0;
margin: 0;
}
#player_container  ul#player_controls li {
overflow:hidden;
text-indent:-9999px;
}
#player_play,
#player_pause {
display: block;
position: absolute;
left:40px;
top:20px;
width:40px;
height:40px;
cursor: pointer;
}
#player_play {
background: url("$fm->{htmlDataFolder}/play/spirites.jpg") 0 0 no-repeat;
}
#player_play.different_prefix_example_hover {
background: url("$fm->{htmlDataFolder}/play/spirites.jpg") -41px 0 no-repeat;
}
#player_pause {
background: url("$fm->{htmlDataFolder}/play/spirites.jpg") 0 -42px no-repeat;
}
#player_pause.different_prefix_example_hover {
background: url("$fm->{htmlDataFolder}/play/spirites.jpg") -41px -42px no-repeat;
}
#player_stop {
position: absolute;
left:90px;
top:26px;
background: url("$fm->{htmlDataFolder}/play/spirites.jpg") 0 -83px no-repeat;
width:28px;
height:28px;
cursor: pointer;
}
#player_stop.different_prefix_example_hover {
background: url("$fm->{htmlDataFolder}/play/spirites.jpg") -29px -83px no-repeat;
}
#player_progress {
position: absolute;
left:130px;
top:32px;
background-color: #eee;
width:122px;
height:15px;
}
#player_progress_load_bar {
background: url("$fm->{htmlDataFolder}/play/bar_load.gif")  top left repeat-x;
width:0px;
height:15px;
cursor: pointer;
}
#player_progress_load_bar.different_prefix_example_buffer {
background: url("$fm->{htmlDataFolder}/play/bar_buffer.gif")  top left repeat-x;
}
#player_progress_play_bar {
background: url("$fm->{htmlDataFolder}/play/bar_play.gif") top left repeat-x ;
width:0px;
height:15px;
}
#player_volume_min {
position: absolute;
left:274px;
top:32px;
background: url("$fm->{htmlDataFolder}/play/spirites.jpg") 0 -170px no-repeat;
width:18px;
height:15px;
cursor: pointer;
}
#player_volume_max {
position: absolute;
left:346px;
top:32px;
background: url("$fm->{htmlDataFolder}/play/spirites.jpg") 0 -186px no-repeat;
width:18px;
height:15px;
cursor: pointer;
}
#player_volume_min.different_prefix_example_hover {
background: url("$fm->{htmlDataFolder}/play/spirites.jpg") -19px -170px no-repeat;
}
#player_volume_max.different_prefix_example_hover {
background: url("$fm->{htmlDataFolder}/play/spirites.jpg") -19px -186px no-repeat;
}
#player_volume_bar {
position: absolute;
left:292px;
top:37px;
background: url("$fm->{htmlDataFolder}/play/volume_bar.gif") repeat-x top left;
width:46px;
height:5px;
cursor: pointer;
}
#player_volume_bar_value {
background: url("$fm->{htmlDataFolder}/play/volume_bar_value.gif") repeat-x top left;
width:0px;
height:5px;
}
#player_playlist_message {
position: absolute;
left:0;
bottom:0;
width:385px;
padding:5px 40px 10px 40px;
font-family: Arial, Helvetica, sans-serif;
line-height:1.4em;
height:1em;
background-color:#ccc;
}
#song_title {
float:left;
margin:0 5px 0 0;
padding:0;
font-weight:bold;
}
#play_time,
#total_time {
padding-top:.3em;
font-weight:normal;
font-style:oblique;
font-size:.7em;
}
#play_time {
float:left;
}
#total_time {        float:right;text-align: right;}
.miaow {
font-size:.8em;
color:#999;
}
.miaow a:link, a:visited, a:hover, a:focus, a:active {        color:#009be3; }
-->
</style>
<div id="container">
<div id="content_main">
<div class="section">
<div id="jquery_jplayer"></div>
<div id="player_container">
<ul id="player_controls">
<li id="player_play">play</li>
<li id="player_pause">pause</li>
<li id="player_stop">stop</li>
<li id="player_volume_min">min volume</li>
<li id="player_volume_max">max volume</li>
</ul>
<div id="player_progress">
<div id="player_progress_load_bar">
<div id="player_progress_play_bar"></div>
</div>
</div>
<div id="player_volume_bar">
<div id="player_volume_bar_value"></div>
</div>
<div id="player_playlist_message">
<div id="song_title">$name</div>
<div id="play_time"></div>
<div id="total_time"></div>
</div>
</div>
</div>
</div>
</div>
</body>
</html>
END
exit;
}
