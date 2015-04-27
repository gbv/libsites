use v5.14.2;
use FindBin;

use constant ROOT   => "$FindBin::Bin/../";
use constant DEVEL  => ($ENV{PLACK_ENV}||'') eq 'development'; 

use lib ROOT."lib";

use Plack::Builder;
use GBV::App::GitUpdate;
use GBV::App::Libsites;
use Plack::App::GitHub::WebHook;

my $app = GBV::App::Libsites->new( root   => 'root' );

builder {
    enable_if { DEVEL } 'Debug';
    enable_if { DEVEL } 'Debug::TemplateToolkit';
    enable_if { DEVEL } 'SimpleLogger';
    enable_if { DEVEL } 'Log::Contextual', level => 'trace';

    builder {
        mount '/update' => GBV::App::GitUpdate->new(
            access    => [ allow => 'all'], # for testing
            work_tree => $app->config,
        )->to_app;
        mount '/' => $app->to_app
    }
};
