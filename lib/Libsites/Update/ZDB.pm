package Libsites::Update::ZDB;
use v5.14;
use Moo;

extends 'Libsites::Update';

use File::Basename;
use Catmandu -all;
use Try::Tiny;

# download and transform ISIL data from ZDB

sub update_isildir {
    my ($self, $dir) = @_;
    
    my $isil = basename($dir);
    my $uri    = "http://ld.zdb-services.de/resource/organisations/$isil";
    my $url    = "http://ld.zdb-services.de/data/organisations/$isil.ttl";
    my $gbvuri = "http://uri.gbv.de/organization/isil/$isil";
    my $file   = "$dir/zdb.ttl";

    my $exporter = exporter('RDF', type => 'turtle', file => $file);

    # TODO: don't die on 404 not found
    try {
        importer('RDF', 
            url => $url, 
            triples => 1, 
            predicate_map => 1,
            fix => [sub {
                my $aref = shift;
                # TODO: aref_translate
                foreach (values %$aref) {
                    s/\Q$uri/$gbvuri/g;
                    s/^\(ISIL\)([^"]+)/$1/g;
                }
                $aref;
            }]
        )->each( sub { $exporter->add($_[0]) } ); 

        $exporter->add({ _id => $uri, owl_sameAs => $gbvuri });
        $exporter->commit;
        $self->{info}->("$url - $file");
    } catch {
        $self->{warn}->("$url - $file failed");
    };
}

1;
