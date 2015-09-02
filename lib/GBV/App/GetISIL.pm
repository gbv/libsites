package GBV::App::GetISIL;
use v5.14.2;

use base 'Exporter';
our @EXPORT = qw(getlod serializettl);

use RDF::Trine::Model;
use RDF::Trine::Parser;

sub getlod($) {
    my $url = shift;

    my $rdf = RDF::Trine::Model->new;
    eval {
        RDF::Trine::Parser->parse_url_into_model( $url, $rdf );
    };
    return (undef,"failed to get $url") if $@;
    return ($rdf,"empty RDF graph from $url") unless $rdf->size;

    return $rdf;
}

use RDF::Trine::Serializer;
use RDF::NS;
use constant NS => RDF::NS->new;

our $prefixes = { map { $_ => NS->{$_} } qw(vcard foaf geo rdfs dcterms owl) };

sub serializettl($) {
    my $rdf = shift;
    return RDF::Trine::Serializer->new('Turtle', namespaces => $prefixes)
        ->serialize_model_to_string( $rdf );
}

1;
