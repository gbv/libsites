use v5.14.2;

use File::Spec::Functions qw(catdir rel2abs);
use File::Basename qw(dirname);
use Plack::Builder;
use GBV::App::Libsites;

my $devel = ($ENV{PLACK_ENV}||'') eq 'development'; 

builder {
    enable_if { $devel } 'Debug';
    enable_if { $devel } 'Debug::TemplateToolkit';
    enable_if { $devel } 'SimpleLogger';
    enable_if { $devel } 'Log::Contextual', level => 'trace';

    GBV::App::Libsites->new(
        root  => rel2abs(catdir(dirname($0),'root')),
        isils => rel2abs(catdir(dirname($0),'libsites-config','isil')),
    );
};
