package GBV::Libsites;
use strict;
use warnings;
use v5.10.1;

use IO::File;
use File::Path qw(make_path);
use RDF::Trine::Model;
use RDF::Trine::Parser;
use RDF::Trine::Serializer;

use parent 'Exporter';
our @EXPORT = qw(get_lod isil_path update_ttl_file);

use RDF::NS;
use constant NS => RDF::NS->new;

our $prefixes = { map { $_ => NS->{$_} } qw(vcard foaf geo rdfs dcterms) };


sub get_lod {
    my $url = shift;

    my $rdf = RDF::Trine::Model->new;
    eval {
        RDF::Trine::Parser->parse_url_into_model( $url, $rdf );
    };
    if ($@) {
        say STDERR "Failed to get $url: $@";
        return;
    }
    return $rdf;
}

sub isil_path {
    my $isil = shift;
    my $path = "isil/$isil";

    make_path($path);
    if( -d $path ) {
        return $path;
    }

    say STDERR "Couldn't create $path: $@";
    return;
}

sub update_ttl_file {
    my ($isil, $name, $rdf) = @_;

    my $path = isil_path( $isil ) or next;
    my $file = "$path/$name.ttl";
    RDF::Trine::Serializer->new('Turtle', namespaces => $prefixes)
        ->serialize_model_to_file(IO::File->new($file,">"),$rdf);

    say "Updated $file with ".$rdf->size." triples";
}

1;
