#!/usr/bin/perl
use strict;
use warnings;
use 5.10.1; 

use File::Spec::Functions qw(catdir catfile rel2abs);
use File::Basename qw(dirname);
use lib rel2abs(catdir(dirname($0),'lib'));
use GBV::Libsites;

die "Missing directory isil/\n" unless -d 'isil';

foreach my $isil (@ARGV) {
    if ($isil !~ qr{^[a-zA-Z0-9:/-]+$}) {
        say STDERR "Invalid ISIL: $isil";
        next;
    }

    my $dbkey = "opac-". lc($isil);
    my $url = "http://uri.gbv.de/database/$dbkey?format=ttl";
    my $rdf = get_lod( $url ) or next;
        # TODO: delete existing graph?

    update_ttl_file( $isil, 'opac', $rdf);
}
