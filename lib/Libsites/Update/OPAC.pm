package Libsites::Update::OPAC;
use v5.14;
use Moo;

extends 'Libsites::Update';

# get corresponding OPAC data via http://uri.gbv.de/database/

use File::Basename;
use Catmandu -all;
use Try::Tiny;

sub update_isildir {
    my ($self, $dir) = @_;

    my $isil  = basename($dir);
    my $dbkey = "opac-". lc($isil);
    my $url   = "http://uri.gbv.de/database/$dbkey?format=ttl";
    my $file  = "$dir/opac.ttl";

    my $exporter = exporter('RDF', type => 'turtle', file => $file);

    try {
        importer('RDF', 
            url => $url, 
            triples => 1, 
            predicate_map => 1,
        )->each( sub { $exporter->add($_[0]) } ); 
        $exporter->commit;
        $self->{info}->("$url - $file");
    } catch {
        $self->{warn}->("$url - $file failed");
    };
}

1;
