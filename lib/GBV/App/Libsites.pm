package GBV::App::Libsites;

use v5.14.2;
use experimental qw(smartmatch);

use parent 'Plack::Component';
use Plack::Util::Accessor qw(root config isil app tt);
use Plack::Builder;

use Log::Contextual qw(:log :dlog);
use Plack::Middleware::TemplateToolkit;
use Plack::App::Directory::Template;
use Plack::App::RDF::Files;
use RDF::Trine::Model;
use RDF::Trine::Parser;
use Time::Piece;
use List::Util qw(max);
use RDF::NS;
use RDF::Lazy;
use constant NS => RDF::NS->new();

sub prepare_app {
    my ($self) = @_;

    my $tt = Plack::Middleware::TemplateToolkit->new( 
        INCLUDE_PATH => $self->root,
        INTERPOLATE  => 1, 
        VARIABLES    => { base => './' },
        vars         => { formats => [qw(ttl rdfxml nt json)] },
        404          => '404.html', 
        500          => '500.html',
        PRE_PROCESS  => 'header.html',
        POST_PROCESS => 'footer.html',
        dir_index    => 'about.html',
    );
    $tt->prepare_app;

    my $app = builder {
        enable 'Static', 
            root => $self->root, 
            path => qr{\.(css|png|gif|js|ico)$};
        enable 'Static',
            root => $self->config,
            path => qr{libsites\.ttl$};
        enable 'JSONP';
        enable 'Negotiate',
            parameter => 'format',
            extension => 0,
            formats => {
                ttl    => { type => 'text/turtle' },
                rdfxml => { type => 'application/rdf+xml' },
                nt     => { type => 'text/plain' },
                n3     => { type => 'text/n3' },
                json   => { type => 'application/rdf+json' },
                html   => { type => 'text/html' },
                _      => { charset => 'utf-8', }
            };
        builder {
            mount '/source' => Plack::App::Directory::Template->new(
                    root => $self->config . '/isil',
                    VARIABLES    => { base => '../../' }, # TODO: dynamic
                    templates    => $self->root,
                    INTERPOLATE  => 1, 
                    PRE_PROCESS  => 'header.html',
                    POST_PROCESS => 'footer.html',
                );
            mount '/isil' => builder {
                enable_if { $_[0]->{'negotiate.format'} eq 'html' } sub {
                    # TODO: directly load via RDF::Files
                    my ($app) = @_;
                    sub {
                        my ($env) = @_;
                        $env->{'negotiate.format'} = 'nt';
                        my $res = $app->($env);
                        Plack::Util::response_cb( $res, sub {
                            my $res = shift;
                            my $uri = $env->{'rdf.uri'};
                            my $rdf = RDF::Trine::Model->new;
                            if ($res->[0] eq '200') {
                                my $parser = RDF::Trine::Parser->new('ntriples');
                                my $data = join '', @{$res->[2]};
                                $parser->parse_into_model( $uri, $data, $rdf );
                            }
                            my $res2 = $self->call_html($env,$rdf);
                            $res->[$_] = $res2->[$_] for (0..2);
                        }); 
                    }
                };
                Plack::App::RDF::Files->new( 
                    base_dir => $self->config . '/' . 'isil',
                    base_uri => 'http://uri.gbv.de/organization/isil/',
                    path_map => sub { $_ = shift; $_ =~ s/\@.+$//; $_ },
                )->to_app;
            };
            mount '/' => $tt;
        };
    };

    $self->tt($tt);
    $self->app($app);
}

sub call_html {
    my ($self, $env, $rdf) = @_;

    my $uri = $env->{'rdf.uri'};
    my $lazy = RDF::Lazy->new( $rdf, namespaces => NS );

    $env->{'tt.vars'}->{uri} = $lazy->resource($uri);
    $env->{'tt.vars'}->{javascript} = [ 'OpenLayers.js' ];
    add_env_sources($env, $uri);
    $env->{'tt.path'} = '/organization.html';   
    $env->{'tt.vars'}{base} = '../';

    $self->tt->call($env);
}
 
sub add_env_sources {
    my ($env, $uri) = @_;
    my $rdffiles = $env->{'rdf.files'};

    my $isil = ($uri =~ /http:\/\/uri.gbv.de\/organization\/isil\/(.+)/ ? $1 : '');
    $isil =~ s/@.*//;

    my @sources; 
    foreach my $file ( keys %$rdffiles ) {
        my $about = $rdffiles->{$file};
        my $s = $file; $s =~ s/\..+$//;
        my %h = (%$about, file => $file);
        given ($s) {
            when('sites') {
                $h{title} = 'GBV Standortverzeichnis';
                $h{href} = "https://github.com/gbv/libsites-config/blob/master/isil/$isil/sites.txt";
            };
            when('opac') {
                $h{'title'} = 'GBV Datenbankverzeichnis';
                $h{'href'} = 'http://uri.gbv.de/database/opac-'.lc($isil);
            };
            when('lobid') { 
                $h{title} = 'lobid.org';
                $h{href} = "http://lobid.org/organisation/$isil";
            };
            when('zdb') {
                $h{title} = 'Deutsches ISIL- und Sigelverzeichnis (PICA)';
                $h{href} = "http://ld.zdb-services.de/resource/organisations/$isil";
            };
            when('zdbrdf') {
                $h{title} = 'Deutsches ISIL- und Sigelverzeichnis (RDF)';
                $h{href} = "http://ld.zdb-services.de/resource/organisations/$isil.rdf";
            };
        }
        push @sources,\%h;
    }

    $env->{'tt.vars'}{sourcedir} = $isil; 
    $env->{'tt.vars'}{sources} = \@sources;
    $env->{'tt.vars'}{timestamp} = localtime( max map { $_->{mtime} } values %$rdffiles )->strftime;

    return @sources; 
}

sub call {
    my ($self, $env) = @_;
    $self->app->($env);
}

1;
