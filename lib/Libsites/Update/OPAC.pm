package Libsites::Update::OPAC;
use v5.14;
use Moo;

extends 'Libsites::Update';

# Holt RDF-Daten zu Katalogen von http://uri.gbv.de/database/
# get corresponding OPAC data via LOD

use GBV::App::GetISIL;
use File::Basename;
use File::Slurp qw(write_file);

sub update_isildir {
    my ($self, $dir) = @_;

    my $isil = basename($dir);
    my $file = "$dir/opac.ttl";

    my $dbkey = "opac-". lc($isil);

    my ($rdf, $msg) = getlod( "http://uri.gbv.de/database/$dbkey?format=ttl" );

    if ($rdf) {
        my $ttl = serializettl( $rdf );
        $msg = "retrieved ".$rdf->size." triples";
    } else {
        $self->{error}->("$file: ".($msg || 'failed'));
        return;
    }

    write_file($file, $rdf);
    $self->{info}->("$file: " . ($msg || "retrieved"));
}

1;
