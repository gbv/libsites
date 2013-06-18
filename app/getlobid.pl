#!/usr/bin/perl
#ABSTRACT: Holt RDF-Daten von Lobid.org
use v5.14;

use FindBin;
use lib "$FindBin::Bin/lib";
use GBV::App::GetISIL;

use RDF::Trine qw(iri statement);

use RDF::NS;
use constant NS => RDF::NS->new;

getisil('lobid.ttl' => sub {
    my $isil = shift;

    my $url = "http://lobid.org/organisation/$isil";
    my ($rdf, $msg) = getlod( $url );
    return (undef, $msg) unless $rdf;

    my @triples = ( 
        [ iri($url), iri(NS->owl_sameAs), iri('http://uri.gbv.de/organization/isil/'.$isil) ],
        [ iri($url), iri(NS->rdf_type), iri(NS->daia_Institution) ],
        [ iri($url), iri(NS->rdf_type), iri(NS->foaf_Organization) ],
        [ iri($url), iri(NS->rdf_type), iri(NS->frbr_CorporateBody) ],
    );
    $rdf->add_statement( statement( @$_ ) ) for @triples;
    
    my $ttl = serializettl( $rdf );
    return ($ttl, "retrieved ".$rdf->size." triples");
});

