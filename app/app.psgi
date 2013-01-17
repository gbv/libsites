#!/usr/bin/perl

use File::Spec::Functions qw(catdir catfile rel2abs);
use File::Basename qw(dirname);
use lib rel2abs(catdir(dirname($0),'lib'));

use Plack::Builder;
use GBV::App::URI::Organization;

my $htdocs = rel2abs(catdir(dirname($0),'htdocs'));

sub is_devel { ($ENV{PLACK_ENV}||'') eq 'development' }

builder {
    enable_if { is_devel } 'Debug';
    enable_if { is_devel } 'Debug::TemplateToolkit';
    enable_if { is_devel } 'ConsoleLogger';
    enable_if { !is_devel } 'SimpleLogger';
    enable_if { is_devel } 'Log::Contextual', level => 'trace';
    enable_if { !is_devel } 'Log::Contextual', level => 'warn';

    GBV::App::URI::Organization->new( htdocs => $htdocs );
};
