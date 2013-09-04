package GBV::App::Libsites::Parser;

use v5.14.2;
use Moo;
use Carp qw(carp);
no if $] >= 5.018, 'warnings', "experimental::smartmatch";

has file => (is => 'ro', default => sub { \*STDIN });
has isil => (is => 'ro');

sub next {
    my ($self) = @_;

    # read first identifier
    carp 'ignored content before first ISIL/code'
        if !$self->{identifier} && $self->parse_location();

    return if !$self->{identifier};
    my %identifier = %{$self->{identifier}};

    my $record = $self->parse_location;
    $record->{$_} = $identifier{$_} for keys %identifier;

    return $record;
}


# until eof or next identifier
sub parse_location {
    my $self = shift;
    $self->{identifier} = undef;

    my ($loc, $has_address);
    my $append = sub {
        $loc->{$_[0]} .= "\n" if defined $loc->{$_[0]};
        $loc->{$_[0]} .= $_[1]; 
    };

    while (readline $self->file) {
        s/^\s+|^\xEF\xBB\xBF|\s+$//g;
        next if /^#/;

        given ($_) {
            when(qr{^(ISIL )?([A-Z]{1,4}-[A-Za-z0-9/:-]+)$}) {
                $self->{identifier} = $2 ~~ $self->isil ? { } : { isil => $2 };
                last;
            };
            when(/^\@([a-z0-9]*)$/) {
                $self->{identifier} = length($1) ? { code => $1 } : { };
                last;
            };
        }
        my $want_address;

        if (!$loc) {
            $loc->{name} = $_;
            next;
        }
        given($_) {
            when('') { };
            when( qr{[^@ ]+@[^@ ]+$} ) {
                $loc->{email} = $_;
            };
            when( qr{^https?://.+$} ) {
                $loc->{url} = $_;
            };
            when(qr{^(\+|\(\+)[0-9\(\)/ -]+$}) { 
                s/\s+/-/g; 
                $loc->{phone} = $_;
            }
            if ($_ =~ /([0-9]{2}:[0-9]{2})|Uhr/ && $_ =~ /(Mo|Di|Mi|Do|Fr|Sa|So)/) {
                $append->( openinghours => $_ );
                break;
            };
            when( qr{^(\d+\.\d+)\s*[,/;]\s*(\d+\.\d+)$} ) {
                $loc->{geolocation} = { 'lat' => $1, 'long' => $2 };
            };
            when ( qr{^(\+|\(\+)[0-9\(\)/ -]+$} ) {
                $loc->{phone} = $_;
            }
            default {
                if ($has_address) {
                    $append->( description => $_ );
                } else {
                    $append->( address => $_ );
                    $want_address = 1;
                }
            };
        };
        $has_address = 1 unless $want_address;
    }

    delete $loc->{name} if $loc && $loc->{name} ~~ '';

    return $loc;
}

=head1 SYNOPSIS

    use GBV::App::Libsites::Parser;

    my $parser = GBV::App::Libsites::Parser->new( file => \*STDIN );
    
    while( my $loc = $parser->next() ) {
        say $loc->{isil}, $loc->{name};
        # ...
    }

=head1 SEE ALSO

L<Catmandu::Importer::Libsites>

=cut

1;
