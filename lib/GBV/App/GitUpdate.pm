use 5.14.2;
package GBV::App::GitUpdate;

use parent 'Plack::Component';
use Plack::Util::Accessor qw(work_tree origin access hook repository);
use Plack::App::GitHub::WebHook;
use Git::Repository;
use Log::Contextual qw(:log);

sub prepare_app {
    my ($self) = @_;

    $self->hook(
        Plack::App::GitHub::WebHook->new(
            hook => [
                sub { $_[0]->{ref} eq "refs/heads/master" },
                sub { $self->pull }
            ],
            access => $self->access,
        )->to_app
    );

    $self->init_repository;
}

sub init_repository {
    my ($self) = @_;

    unless ( -d $self->work_tree and -d $self->work_tree . '/.git') {
        if ( $self->origin ) {
            Git::Repository->run( 'clone', $self->origin, $self->work_tree );
        }
    }

    if (-d $self->work_tree . '/.git') {
        $self->repository(
            eval { 
                Git::Repository->new( work_tree => $self->work_tree )
            }
        );
    }
}

sub pull {
    my ($self) = @_;

    $self->init_repository unless ($self->repository);
    return unless $self->repository;

    $self->repository->run('pull origin master');

    chdir $self->work_tree;

    system('make','sites'); # TODO: update
}

sub call {
    my ($self, $env) = @_;

    if (($env->{HTTP_X_GITHUB_EVENT} // '') eq 'push') {
        $self->hook->($env);
    } else {
        [400,[],["GitHub event type not accepted"]];
    }
}

1;
