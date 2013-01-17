#!/usr/bin/perl
use strict;
use warnings;
use 5.10.1; 

use File::Path qw(make_path);
use IO::File;
use RDF::Trine qw(iri statement);
use RDF::Trine::Model;
use RDF::Trine::Parser;
use RDF::Trine::Serializer;

use RDF::NS;
use constant NS => RDF::NS->new;

our $prefixes = { map { $_ => NS->{$_} } qw(vcard foaf geo rdfs dcterms) };

die "Missing directory isil/\n" unless -d 'isil';

foreach my $isil (@ARGV) {
    if ($isil !~ qr{^[a-zA-Z0-9:/-]+$}) {
        say STDERR "Invalid ISIL: $isil";
        next;
    }

    #### first, retrieve

    my $rdf = RDF::Trine::Model->new;
    my $url = "http://lobid.org/organisation/$isil";
    eval {
        RDF::Trine::Parser->parse_url_into_model( $url, $rdf );
    };
    if ($@) {
        say STDERR "Failed to get $url";
        next;
    };

    #### second, transform

    my @triples = ( 
        [ iri($url), iri(NS->owl_sameAs), iri('http://uri.gbv.de/organization/isil/'.$isil) ],
        [ iri($url), iri(NS->rdf_type), iri(NS->daia_Institution) ],
        [ iri($url), iri(NS->rdf_type), iri(NS->foaf_Organization) ],
        [ iri($url), iri(NS->rdf_type), iri(NS->frbr_CorporateBody) ],
    );
    $rdf->add_statement( statement( @$_ ) ) for @triples;

    #### third, write as RDF/Turtle

    my $path = "isil/$isil";
    make_path($path);
    unless( -d $path ) {
        say STDERR "Couldn't create $path: $@";
        next;
    }
    
    my $file = "$path/lobid.ttl";
    RDF::Trine::Serializer->new('Turtle', namespaces => $prefixes)
        ->serialize_model_to_file(IO::File->new($file,">"),$rdf);
    say "Updated $file with ".$rdf->size." triples";
}

