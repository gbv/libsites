#!/usr/bin/env perl
#ABSTRACT: Holt RDF-Daten zu Katalogen von http://uri.gbv.de/database/
use v5.14;

use FindBin;
use lib "./lib";
use GBV::App::GetISIL;

getisil 'opac.ttl' => sub {
    my $isil = shift;
    my $dbkey = "opac-". lc($isil);

    my ($rdf, $msg) = getlod( "http://uri.gbv.de/database/$dbkey?format=ttl" );
    return (undef, $msg) unless $rdf;

    my $ttl = serializettl( $rdf );
    return ($ttl, "retrieved ".$rdf->size." triples");
};
