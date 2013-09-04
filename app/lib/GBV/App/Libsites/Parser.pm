package GBV::App::Libsites::Parser;

use v5.14.2;
use Moo;

has file => (is => 'ro', default => sub { \*STDIN });
has isil => (is => 'ro');

sub next {
    my ($self) = @_;

    # read first identifier
    unless ($self->{identifier}) {
        warn 'ignored content before first ISIL/code'
            if $self->parse_location();
    }

    return unless $self->{identifier};

    my @identifier = @{ $self->{identifier} };

    my $record = $self->parse_location;

    if ($record && @identifier) {
        $record->{$identifier[0]} = $record->{$identifier[1]};
    }

    return $record;
}

no if $] >= 5.018, 'warnings', "experimental::smartmatch";

# until eof or next identifier
sub parse_location {
    my $self = shift;
    my $location;
    my $has_address;

    while (readline $self->file) {
        s/^\s+|^\xEF\xBB\xBF|\s+$//g;
        next if /^#/;

        given ($_) {
            when(qr{^(ISIL )?([A-Z]{1,4}-[A-Za-z0-9/:-]+)$}) {
                $self->{identifier} = $2 ~~ $self->isil ? [ ] : [ isil => $2 ];
                last;
            };
            when(/^\@([a-z0-9]*)$/) {
                $self->{identifier} = length($1) ? [ code => $1 ] : [ ];
                last;
            };
        }
        if (!$location) {
            $location->{name} = $_;
            next;
        }
        my $want_address;
        for($_) {
            $location->{email} = $_ when qr{[^@ ]+@[^@ ]+$};
            $location->{url} = $_   when qr{^https?://.+$};
            when(qr{^(\+|\(\+)[0-9\(\)/ -]+$}) { s/\s+/-/g; $location->{phone} = $_; }
            # when(qr{(\d\d:\d\d|Uhr)}) {
            #        and $_ =~ qr{(Mo|Di|Mi|Do|Fr|Sa|So)}
            # TODO: more fields
            when('') { };
            default {
                if ($has_address) {
                    $_ = " $_" if defined $location->{description};
                    $location->{description} .= $_;
                } else {
                    $_ = " $_" if defined $location->{address};
                    $location->{address} .= $_;
                    $want_address = 1;
                }
            };
        };
        $has_address = 1 unless $want_address;
    }

    return $location;
}

=head1 SYNOPSIS

    use GBV::App::Libsites::Parser;

    my $parser = GBV::App::Libsites::Parser->new( file => \*STDIN );
    
    while( my $loc = $parser->next() ) {
        say $loc->{isil};
        # ...
    }

=head1 SEE ALSO

L<Catmandu::Importer::Libsites>

=cut

1;
