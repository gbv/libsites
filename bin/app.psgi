#!/usr/bin/perl

use File::Spec::Functions qw(catdir catfile rel2abs);
use File::Basename qw(dirname);
use lib rel2abs(catdir(dirname($0),'lib'));

use Plack::Builder;

my $app = sub {
    return [200,[],["Hello"]];
};

$app;

