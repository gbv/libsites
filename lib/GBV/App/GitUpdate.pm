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

    if (-d '/var/log/libsites') {
        open $self->{logfile}, '>>', '/var/log/libsites/update.log';
    }

    $self->init_repository;
}

sub log {
    my ($self, $msg) = @_;

    if ($self->{logfile}) {
        print {$self->{logfile}} $msg;
    }
}

sub init_repository {
    my ($self) = @_;

    unless ( -d $self->work_tree and -d $self->work_tree . '/.git') {
        if ( $self->origin ) {
            $self->log("cloning ".$self->origin);
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

# TODO: log all this actions!

sub pull {
    my ($self) = @_;

    $self->init_repository unless $self->repository;
    return unless $self->repository;

    $self->log("git pull in ".$self->work_tree);
    $self->repository->run('pull','origin','master');

    # TODO: this does not work (???)
    my $log = "";
    chdir $self->work_tree;
    open P, 'eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib) && make deps && make sites |';
    while (<P>) {
        $self->log($_);
    }
    close P;
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
