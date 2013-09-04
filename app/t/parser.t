use v5.14.2;
use Test::More;

use_ok('GBV::App::Libsites::Parser');

my $parser = GBV::App::Libsites::Parser->new( file => \*DATA );

is_deeply ($parser->next(), { 
    name        => 'Main Library', 
    url         => 'http://example.org/',
    address     => 'an address',
    description => 'some comment',
});

__DATA__
@
Main Library
an
# ignore
address
http://example.org/
some
comment
