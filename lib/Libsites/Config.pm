package Libsites::Config;
use v5.14;
use Moo;
use Cwd qw(realpath);

our $exists = sub {
    -d $_[0] ? realpath($_[0]) : die "missing directory $_[0]\n"
};

has configdir => (
    is      => 'rw',
    builder => sub {
        $ENV{LIBSITES_CONFIG} // 
            (-d 'libsites-config' ? 'libsites-config' : '/etc/libsites')
    },
    coerce => $exists,
);

has updatelog => (
    is      => 'rw',
    builder => sub {
        $ENV{LIBSITES_LOG} // 
            (-d '/var/log/libsites' ? '/var/log/libsites/update.log' : undef);
    },
    coerce => sub {
        my $file = $_[0] ? $_[0] : return *STDOUT;
        open (my $fh, '>>', $file) or die "failed to open logfile $file\n";
        $fh
    }
);

1;
