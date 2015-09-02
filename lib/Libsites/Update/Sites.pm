package Libsites::Update::Sites;
use v5.14;

use Moo;
extends 'Libsites::Update';

use Catmandu qw(importer exporter);
use Catmandu::Fix::libsites_rdf;
use JSON;
use File::Basename;

sub update_isildir {
    my ($self, $dir) = @_;

    my $sites = "$dir/sites.txt";
    return unless -e $sites;

    state $rdf_fix = Catmandu::Fix::libsites_rdf->new;

    my $yaml_exporter = exporter( 'YAML', file => $dir.'/sites.yml' );
    my $rdf_exporter  = exporter( 'RDF', file => $dir.'/sites.ttl', type => 'Ntriples' );

    my $model = RDF::Trine::Model->new;

    my $isil = basename($dir);
    importer('Libsites', file => $sites, isil => $isil)->each(sub{
        $yaml_exporter->add($_[0]);
        my $aref = $rdf_fix->fix($_[0]);
        $rdf_exporter->add($aref);
    });

    $yaml_exporter->commit;
    $rdf_exporter->commit;

    $self->{info}->("$dir/sites.{yml,ttl} - ".$rdf_exporter->count." departments");
}

1;
