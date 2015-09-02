package GBV::App::Libsites;

use v5.14.2;
no warnings 'experimental::smartmatch';

use parent 'Plack::Component';
use Plack::Util::Accessor qw(config isil app tt);
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

sub prepare_app { # sub BUILD
    my ($self) = @_;

    # TODO: 'with
    for ($ENV{LIBSITES_CONFIG}, './libsites-config', '/etc/libsites') {
        $self->config($_);
        last if -d $_;
    }

    my $isildir = $self->config . '/isil';
    mkdir $isildir unless -d $isildir;

    my $tt = Plack::Middleware::TemplateToolkit->new( 
        INCLUDE_PATH => 'public',
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
            root => 'public', 
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
                    root         => $isildir,
                    VARIABLES    => { base => '../../' }, # TODO: dynamic
                    templates    => 'public',
                    INTERPOLATE  => 1, 
                    PRE_PROCESS  => 'header.html',
                    POST_PROCESS => 'footer.html',
                );
            mount '/isil' => builder {
                enable_if { $_[0]->{'negotiate.format'} eq 'html' } sub {
                    my ($app) = @_;
                    sub {
                        my ($env) = @_;
                        $env->{'psgi.streaming'} = 1;
                        $env->{'negotiate.format'} = 'nt';
                        my $res = $app->($env);

                        Plack::Util::response_cb( $res, sub {
                            my $res = shift;
                            my $uri = $env->{'rdf.uri'};
                            my $iter = $env->{'rdf.iterator'};
                            my $model = RDF::Trine::Model->new;
                            if ($res->[0] eq '200' and $iter) {
                                $model->add_iterator($iter);
                            }
                            my $res2 = $self->call_html($env,$model);
                            $res->[$_] = $res2->[$_] for (0..2);
                        }); 
                    }
                };
                Plack::App::RDF::Files->new( 
                    base_dir => $isildir,
                    base_uri => 'http://uri.gbv.de/organization/isil/',
                    path_map => sub { $_ = shift; $_ =~ s/\@.+$//; $_ },
                    normalize => 'NFC',
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
