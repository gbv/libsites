package Libsites::Update::ISIL;
use v5.14;
use Moo;

extends 'Libsites::Update';

use File::Path qw(make_path);

# create ISIL directories from isil.csv

sub update {
    my $self = shift;
    
    my $file = $self->configdir.'/isil.csv';

    open (my $fh, '<', $file) or do {
        $self->{error}->("failed to open $file");
        return;
    };

    foreach (<$fh>) {
        chomp;
        # TODO: validate ISIL!
        my $dir = $self->configdir."/isil/$_";
        return if -d $dir;
        $self->{info}->("\$ mkdir $dir");
        mkdir $dir;
    }
}

1;
