use strict;
use Test::More;
use Plack::Test;
use Plack::Util;
use HTTP::Request::Common;

my $app = Plack::Util::load_psgi('bin/app.psgi');

test_psgi $app, sub {
    my $cb = shift;
    my $res = $cb->(GET '/');
    is $res->code, 200, 'HTTP response OK at /';

    # $res = $cb->(GET "/isil/DE-1a");
    # is $res->code, 200;
};

done_testing;
