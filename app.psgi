use v5.14.2;
use lib 'lib';
use lib 'local/lib/perl5';

use Plack::Builder;
use GBV::App::GitUpdate;
use GBV::App::Libsites;
use Plack::App::GitHub::WebHook;

my $app = GBV::App::Libsites->new;

builder {
    mount '/update' => GBV::App::GitUpdate->new(
        access    => [ allow => 'all'], # for testing
        work_tree => $app->config,
    )->to_app;
    mount '/' => $app->to_app
};
