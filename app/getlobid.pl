#!/usr/bin/perl
#ABSTRACT: Holt RDF-Daten von Lobid.org
use v5.14;

use FindBin;
use lib "$FindBin::Bin/lib";
use GBV::App::GetISIL;

use RDF::Trine qw(iri statement);
use RDF::Trine::Model;
use RDF::NS;
use constant NS => RDF::NS->new;

my $lobidbase = "http://lobid.org/organisation/";
my $gbvbase = "http://uri.gbv.de/organization/isil/";

getisil('lobid.ttl' => sub {
    my $isil = shift;

    my $url = "$lobidbase$isil";
    my ($rdf, $msg) = getlod( $url );
    return (undef, $msg) unless $rdf;

    my @triples;
    my $rdf2 = RDF::Trine::Model->new;
    my $iter = $rdf->as_stream;
    while (my $st = $iter->next) {
        push @triples, [
            map {
                if ($_->is_resource && $_->uri =~ /^$lobidbase(.+)$/) {
                    $_->uri( $gbvbase.$1 );
                }
                $_;
            }
            $st->nodes
        ];
    }
    $rdf = RDF::Trine::Model->new;


    my $uri = $gbvbase.$isil;

    push @triples, 
        [ iri($uri), iri(NS->owl_sameAs), iri($url) ],
        [ iri($uri), iri(NS->rdf_type), iri(NS->daia_Institution) ],
        [ iri($uri), iri(NS->rdf_type), iri(NS->foaf_Organization) ],
        [ iri($uri), iri(NS->rdf_type), iri(NS->frbr_CorporateBody) ]
    ;
    $rdf->add_statement( statement( @$_ ) ) for @triples;
    
    my $ttl = serializettl( $rdf );
    return ($ttl, "retrieved ".$rdf->size." triples");
});

