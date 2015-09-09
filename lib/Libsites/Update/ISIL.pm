package Libsites::Update::ISIL;
use v5.14;
use Moo;

extends 'Libsites::Update';

use File::Path qw(make_path);

# create ISIL directories from isil.csv

sub update {
    my $self = shift;
    
    my $file = $self->configdir.'/isil.csv';
    $self->{info}->("Creating isil directories listed in $file");

    open (my $fh, '<', $file) or do {
        $self->{error}->("failed to open $file");
        return;
    };

    foreach my $isil (<$fh>) {
        chomp $isil;
        if ($isil !~ /^[A-Z]{1,3}-[A-Za-z0-9\/:-]{1,10}$/) {
            $self->{warn}->("invalid ISIL $isil");
            next;
        }
        my $dir = $self->configdir."/isil/$isil";
        next if -d $dir;
        $self->{info}->("\$ mkdir $dir");
        mkdir $dir;
    }
}

1;
