package Catmandu::Importer::libsites;

use namespace::clean;
use Catmandu::Sane;
use Moo;

use GBV::App::Libsites::Parser;

with 'Catmandu::Importer';

sub generator {
    my ($self) = @_;
    sub {
        state $parser = GBV::App::Libsites::Parser->new( file => $self->fh );
        return $parser->next;
    };
}

1;
