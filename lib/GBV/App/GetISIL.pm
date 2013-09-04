package GBV::App::GetISIL;
use v5.14;

use GBV::App::Logger;

use base 'Exporter';
our @EXPORT = qw(getisil getlod serializettl);

use File::Path qw(make_path);
use File::Slurp qw(write_file);

sub getisil(@) {
    my %files = @_;

    die "missing directory libsites-config/isil/\n" unless -d 'libsites-config/isil';

    foreach my $isil (@ARGV) {
        if ($isil !~ qr{^[a-zA-Z0-9:/-]+$}) {
            say STDERR "invalid ISIL: $isil";
            next;
        }

        foreach my $file (keys %files) {
            my ($data, $message) = $files{$file}->($isil);

            if (!defined $data) { 
                $message ||= "failed";
                say STDERR "$isil/$file: $message";
                next;
            }
    
            my $path = "libsites-config/isil/$isil";
            make_path $path;
            unless( -d $path ) {
                say STDERR "couldn't create $path: $@";
                next;
            }
      
            $file = "$path/$file";
            write_file( $file, $data );
            say "$file: " . ($message || "retrieved");
        }
    }
}

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
