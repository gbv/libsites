#!/usr/bin/perl
use v5.14;

use File::Path qw(make_path);
use File::Slurp;
use PICA::Source;
use Encode;

die "Missing directory isil/\n" unless -d 'isil';

my $sru = PICA::Source->new( SRU => 'http://sru.gbv.de/isil' );

foreach my $isil (@ARGV) {
    if ($isil !~ qr{^([A-Z]+)-([a-zA-Z0-9:/-]+)$}) {
        say STDERR "Invalid ISIL: $isil";
        next;
    } else {
        $isil = "$1-".ucfirst($2);
    }

    ## retrieve
    my ($pica) = $sru->cqlQuery("pica.isi=$isil")->records();
    unless ($pica and $pica->sf('008H$e') eq $isil) {
        say STDERR "Failed to retrieve $isil";
        next;
    }

    ## write
    my $path = "isil/$isil";
    make_path($path);
    unless( -d $path ) {
        say STDERR "Couldn't create $path: $@";
        next;
    }

    my $file = "$path/isildir.pica";

    $pica = encode('UTF-8',decode('ISO-8859-1',"$pica"));
    write_file( $file, $pica );
    say $file;
}
