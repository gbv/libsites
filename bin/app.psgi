use v5.14.2;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Plack::Builder;
use GBV::App::Libsites;

my $devel = ($ENV{PLACK_ENV}||'') eq 'development'; 
my $config = "$FindBin::Bin/../libsites-config";
$config = '/etc/libsites' unless -e $config;

builder {
    enable_if { $devel } 'Debug';
    enable_if { $devel } 'Debug::TemplateToolkit';
    enable_if { $devel } 'SimpleLogger';
    enable_if { $devel } 'Log::Contextual', level => 'trace';

    GBV::App::Libsites->new(
        root   => 'root',
        config => $config
    );
};
