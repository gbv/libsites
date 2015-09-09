package Libsites::Update::Webhook;
use v5.14;

use Moo;
extends 'Libsites::Update';

use Libsites::Update::Sites;
use Plack::App::GitHub::WebHook;
use GitHub::WebHook::Clone;
use Cwd qw(cwd);

has clone_hook => (
    is      => 'lazy',
    builder => sub {
        GitHub::WebHook::Clone->new(
            work_tree => $_[0]->configdir,
        )
    }
);

# returns a PSGI app to receive webhooks from GitHub
sub to_app {
    my $self = shift;

#    my $cur = cwd;
    my $app = Plack::App::GitHub::WebHook->new(
        access => 'all',
        hook => [ 
            $self->clone_hook,
            sub {
                chdir $self->configdir;
                Libsites::Update::Sites->new->update;
            }
        ]
    );

    sub { 
        my $env = shift;
        $env->{'psgix.logger'} = $self;
        $app->($env);
    }
}

sub update {
    my $self = shift;

    my $cur = cwd;
    $self->clone_hook->call( 
        { repository => { clone_url => 'origin' } },             
        'direct-update', 1, 
        $self # logger
    );
    chdir $cur;
}

1;
