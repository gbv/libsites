use v5.14.2;
use FindBin;

use constant ROOT   => "$FindBin::Bin/../";
use constant CONFIG => -e ROOT.'libsites-config' ? ROOT.'libsites-config' : '/etc/libsites';
use constant DEVEL  => ($ENV{PLACK_ENV}||'') eq 'development'; 

use lib ROOT."lib";

use Plack::Builder;
use GBV::App::GitUpdate;
use GBV::App::Libsites;
use Plack::App::GitHub::WebHook;

builder {
    enable_if { DEVEL } 'Debug';
    enable_if { DEVEL } 'Debug::TemplateToolkit';
    enable_if { DEVEL } 'SimpleLogger';
    enable_if { DEVEL } 'Log::Contextual', level => 'trace';

    builder {
        mount '/update' => GBV::App::GitUpdate->new(
            access    => [ allow => 'all'], # for testing
            work_tree => CONFIG
        )->to_app;
        mount '/' => GBV::App::Libsites->new(
            root   => 'root',
            config => CONFIG
        )->to_app;
    }
};
