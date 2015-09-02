use v5.14;
use Test::More;
use Test::Fatal;
use File::Temp;

plan skip_all => 'whitebox test' if $ENV{TEST_URL};

$ENV{LIBSITES_CONFIG} = (my $configdir = 't/config');
$ENV{LIBSITES_LOG}  //= (my $updatelog = File::Temp->new->filename);

{
    use_ok 'Libsites::Update::Webhook';
    my $hook   = new_ok 'Libsites::Update::Webhook';
    ok $hook->to_app, 'webhook app created';
}

if ($ENV{LIBSITES_LOG}) {
    ok -e $updatelog, "logfile exists";
}

{
    use_ok 'Libsites::Update::ISIL';
    my $isil = new_ok 'Libsites::Update::ISIL';
    $isil->update;
    ok -d 't/config/isil/DE-456', 'ISIL update';
    rmdir 't/config/isil/DE-456';
}

{
    use_ok 'Libsites::Update::Sites';
    my $sites = new_ok 'Libsites::Update::Sites';
    $sites->update;

    my $example = "$configdir/isil/DE-ABCDE";
    ok -e "$example/sites.ttl", "sites.txt => sites.ttl";
    ok -e "$example/sites.yml", "sites.txt => sites.yml";
}

{
    use_ok 'Libsites::Update::ZDB';
    my $zdb = new_ok 'Libsites::Update::ZDB';
}

{
    use_ok 'Libsites::Update::OPAC';
    my $opac = new_ok 'Libsites::Update::OPAC';
}

done_testing;
