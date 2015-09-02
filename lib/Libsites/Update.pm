package Libsites::Update;
use v5.14;
use Moo;
use File::Basename;

extends 'Libsites::Config';

# create logging methods
sub BUILD {
    my $self = shift;
    foreach my $level (qw(debug info warn error)) {
        # ignore log levels, just print all messages
        $self->{$level} = sub { 
            say {$self->updatelog} $_[0];
        }
    }
}

# execute update_isildir on all given or all existing isil directories
sub update {
    my ($self, @dirs) = @_;

    @dirs = grep { -d $_ } glob $self->configdir.'/isil/*' if !@dirs;

    foreach my $dir ( @dirs ) {
        $dir =~ s{/$}{};

        if (!-d $dir) {
            $self->{warn}->("not a directory: $dir");
            next;
        }

        my $isil = basename($dir);

        if ($isil !~ /^[A-Z]{1,3}-[A-Za-z0-9\/:-]{1,10}$/) {
            $self->{warn}->("invalid ISIL $isil");
            next;
        }

        $self->update_isildir($dir, $dir);
    }
}

1;
