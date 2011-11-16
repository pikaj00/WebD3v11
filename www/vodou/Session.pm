package Session;
use strict;
#************************************************************************************
#Build 1011A0001
#************************************************************************************
use Digest::MD5;
use Storable;
use Fcntl (':DEFAULT', ':flock');
use vars qw($PREFFIX);
$PREFFIX = "cgisess_";
sub new {
my $class = shift;
$class = ref($class) || $class;
my $sid = shift;
my $data = shift;
my $self = {};
bless ($self, $class);
$self->setSid($sid);
$self-> _Init($data);
$self->retrieve if $sid;
return $self;
}
sub _Init
{
my $self = shift;
my $data = shift;
if(ref $data eq 'HASH'){
@$self{keys %$data} = values %$data;
}
$self->{_file_path} = $self->{Directory}."/$PREFFIX".$self->{_sid};
return $self;
}
sub setSid {
my $self = shift;
my $sid = shift;
if ($sid){}
else {$sid=$self->generate_id;}
$self->{_sid}=$sid;
return $sid;
}
sub generate_id {
my $self = shift;
my $md5 = new Digest::MD5();
$md5->add($$ , time() , rand(9999) );
return $md5->hexdigest();
}
sub store {
my $self=shift;
Storable::store($self->{_data}, $self->{_file_path}) or die "Can't store data!\n";
return 1;
}
sub id{
my $self = shift;
return $self->{_sid};
}
sub retrieve {
my $self = shift;
$self->{_data} = Storable::retrieve($self->{_file_path});
return $self->{_data};
}
sub param {
my ($self,$key,$value) = @_;
if($value){
$self->{_data}->{$key}=$value;
$self->store;
}
return $self->{_data}->{$key};
}
1;
