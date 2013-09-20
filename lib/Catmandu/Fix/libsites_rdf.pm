package Catmandu::Fix::libsites_rdf;

use v5.14.1;
use Moo;

has isil => (is => 'rw');

our $isilbase = "http://uri.gbv.de/organization/isil/";

sub fix {
    my ($self, $record) = @_;

    $record->{isil}   = $isilbase . $record->{isil};
    $record->{parent} = $isilbase . $record->{parent};

    my $rdf = {
        'rdf:type' => 'foaf:Organization'
    };

    if ($record->{isil}) {
        $rdf->{'@id'} = $record->{isil};
    }

    if ($record->{parent}) {
        $rdf->{'org:siteOf'} = $record->{isil};
    }

    $rdf;
}

1;
