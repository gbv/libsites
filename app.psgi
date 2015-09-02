use v5.14;
use Plack::Builder;
use GBV::App::Libsites;
use Libsites::Update::Webhook;

builder {
    mount '/update' => Libsites::Update::Webhook->new->to_app;
    mount '/'       => GBV::App::Libsites->new->to_app;
};
