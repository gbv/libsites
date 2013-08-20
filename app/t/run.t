use strict;
use Test::More;
use Plack::Test;
use Plack::Builder;

=head1
my $app = GBV::App::Libsites->new();

test_psgi $app, sub {
    my $cb = shift;

    my $res = $cb->(GET "/isil/DE-1a");
    is $res->code, 200;
};
=cut

done_testing;
