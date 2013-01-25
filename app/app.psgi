#!/usr/bin/perl
use strict;

use File::Spec::Functions qw(catdir catfile rel2abs);
use File::Basename qw(dirname);
use lib rel2abs(catdir(dirname($0),'lib'));

use Plack::Builder;
use Plack::Util;
use Plack::App::RDF::Files;

use RDF::NS;
my $NS = RDF::NS->new;
use RDF::Lazy;
use RDF::Trine::Model;
use RDF::Trine::Parser;
use Plack::Middleware::TemplateToolkit;
use CHI;

my $htdocs = rel2abs(catdir(dirname($0),'htdocs'));

sub is_devel { ($ENV{PLACK_ENV}||'') eq 'development' }

my $html_app = Plack::Middleware::TemplateToolkit->new( 
        INCLUDE_PATH => $htdocs,
        INTERPOLATE => 1, 
        timer => is_devel,
        vars => { formats => [qw(ttl rdfxml nt json)] },
        request_vars => [qw(base)],
        404 => '404.html', 
        500 => '500.html',
    );
$html_app->prepare_app;

builder {
    enable_if { is_devel } 'Debug';
    enable_if { is_devel } 'Debug::TemplateToolkit';
    enable_if { is_devel } 'ConsoleLogger';
    enable_if { !is_devel } 'SimpleLogger';
    enable_if { is_devel } 'Log::Contextual', level => 'trace';
    enable_if { !is_devel } 'Log::Contextual', level => 'warn';

    enable 'Static', 
        root => $htdocs, 
        path => qr{\.(css|png|gif|js|ico)$};

    # cache everything else for 10 seconds. TODO: set cache time
    enable 'Cached',
            cache => CHI->new( 
                driver => 'Memory', global => 1, 
                expires_in => '10 seconds' 
            );

    enable 'JSONP';
    enable 'Negotiate',
        parameter => 'format',
        extension => 'strip',
        formats => {
            'ttl' => { type => 'text/turtle' },
            'nt' => { type => 'text/plain' },
            'n3' => { type => 'text/n3' },
            'json' => { type => 'application/rdf+json' },
            'html' => { type => 'text/html' },
            _ => { charset => 'utf-8', }
        };

    enable sub {
        my $app = shift;
        return sub {
            my $env = shift;
            return $app->($env) 
                unless $env->{'negotiate.format'} eq 'html';
            $env->{'negotiate.format'} = 'nt';
            Plack::Util::response_cb( $app->($env), sub {
                my $res = shift;
                my $uri = $env->{'rdflow.uri'};

                # TODO: get via $env->{'rdflow.data'} to avoid re-parsing
                my $rdf = RDF::Trine::Model->new;
                if ($res->[0] eq '200') {
                    my $parser = RDF::Trine::Parser->new('ntriples');
                    my $data = join '', @{$res->[2]};
                    $parser->parse_into_model( $uri, $data, $rdf );
                }

                my $lazy = RDF::Lazy->new( $rdf, namespaces => $NS );
                $env->{'tt.vars'}->{uri} = $lazy->resource($uri);
                $env->{'tt.vars'}->{javascript} = [ 'OpenLayers.js' ];

                $env->{'tt.path'} = '/organization.html';   
                my $res2 = $html_app->call( $env );

                $res->[$_] = $res2->[$_] for (0..2);
            } );
        };
    };

    Plack::App::RDF::Files->new( 
        base_dir => rel2abs(catdir(dirname($0),'..','isil')),
        base_uri => 'http://uri.gbv.de/organization/isil/',
        path_map => sub { $_ = shift; $_ =~ s/\@.+$//; $_ },
    );
};
