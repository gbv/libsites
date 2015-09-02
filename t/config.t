use Test::More;
use Test::Fatal;
use v5.14;

plan skip_all => 'whitebox test' if $ENV{TEST_URL};

use Cwd qw(realpath);
use File::Temp qw(tempdir);
use Libsites::Config;
use Fcntl;

sub writeable {
    (O_WRONLY | O_RDWR) & fcntl(shift, F_GETFL, my $dummy);
}

$ENV{LIBSITES_CONFIG} = (my $configdir = realpath('t/config'));
$ENV{LIBSITES_LOG}    = (my $logdir = tempdir(CLEANUP => 1)).'/update.log';

my $conf = new_ok 'Libsites::Config';

is $conf->configdir, $configdir, 'configdir';
ok writeable($conf->updatelog), 'updatelog';

$ENV{LIBSITES_LOG} = "$logdir/missing/file";
ok exception { Libsites::Config->new }, 'updatelog must be writeable';

$ENV{LIBSITES_LOG} = "$logdir/update.log";
$ENV{LIBSITES_CONFIG} = "$logdir/missing";
ok exception { Libsites::Config->new }, 'configdir must exist';

mkdir "$logdir/libsites-config";
delete $ENV{LIBSITES_CONFIG};
chdir $logdir;

my $conf = Libsites::Config->new;
is $conf->configdir, "$logdir/libsites-config", "default config in ./libsites-config";

unless (-d '/var/log/libsites') {
    delete $ENV{LIBSITES_LOG};
    $conf = Libsites::Config->new;
    is $conf->updatelog, *STDOUT, "default updatelog to STDOUT";
}

done_testing;
