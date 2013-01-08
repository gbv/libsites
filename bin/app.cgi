#!/usr/bin/perl
#ABSTRACT: Execute app.psgi as CGI

use File::Spec::Functions qw(catdir catfile rel2abs);
use File::Basename qw(dirname);

use Plack::Loader;
use Plack::Util;

my $psgi = rel2abs(catdir(dirname($0),'app.psgi'));
my $app  = Plack::Util::load_psgi($psgi);

Plack::Loader->auto->run($app);
