use strict;
use Test::More;
use Plack::Test;
use Plack::Util::Load;
use HTTP::Request::Common;

plan skip_all => 'blackbox test' unless $ENV{TEST_URL};

my $app = load_app($ENV{TEST_URL});

test_psgi $app, sub {
    my $cb = shift;
    my $res = $cb->(GET '/');
    is $res->code, 200, 'HTTP response OK at /';
};

done_testing;
