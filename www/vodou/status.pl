#!/usr/bin/perl

#************************************************************************************
#Build 1011A0001
#************************************************************************************

####Status Tempoary Folder#########################################

my $tmpDir = "./status";
#Please enter the path to the "status" folder
###################################################################

use CGI::Carp qw(fatalsToBrowser);
(my $script=$0) =~s!^.*[/\\]!!;
my %FORM = parse_cgi();
print "Cache-control: private\n";
print "Cache-control: no-cache\n";
print "Cache-control: no-store\n";
print "Cache-control: must-revalidate\n";
print "Cache-control: proxy-revalidate\n";
print "Cache-control: max-age=0\n";
print "Pragma: no-cache\n";
print "Content-type: text/html\n\n";
unless($FORM{session}){
print "1";
exit;
}
if ($FORM{type} eq 'clear'){
unlink "$tmpDir/$FORM{session}";
unlink "$tmpDir/$FORM{session}.tmp";
print "1";
exit;
}
unless (-f "$tmpDir/$FORM{session}"){
print qq~$FORM{session}\n0 0 0~;
exit;
}
local $/;
open (F, "$tmpDir/$FORM{session}") or die "Can't open file $! $tmpDir/$FORM{session}";
#flock(ST, LOCK_EX);
my $data = <F>;
close F;
my($lenght, $proz, $time)=split(' ',$data);
$lenght = sprintf("%.2f", $lenght/1024);
my $curTime=time;
my $diff = $curTime-$time;
my $speed=0;
if($diff && $lenght*$proz){$speed=sprintf("%.3f",($lenght*$proz/100)/($diff))}; #Kb/sec
if($proz<100){
print qq~$FORM{session}\n$lenght $proz $speed~;
}
else{
print qq~$FORM{session}\n$lenght 100 $speed~;
}
exit;
sub parse_cgi{
my(%FORM, $buffer);
my @pairs=split(/&/,$ENV{'QUERY_STRING'});
foreach my $pair (@pairs) {
my ($name, $value) = split (/=/,$pair,2);
$value =~ tr/+/ /;
$value =~ s/%(..)/pack("c",hex($1))/ge;
$FORM{$name} = $value;
}
return %FORM;
}
