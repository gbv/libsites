# basic frameworks
requires 'Plack', '1.0';
requires 'Moo', '1.0';
requires 'Catmandu', '0.7';
requires 'Carton';

# Plack middleware and applications modules
requires 'Plack::Middleware::Log::Contextual', '0.01';
requires 'Plack::Middleware::Rewrite', '1.0';
requires 'Plack::Middleware::Debug', '0.16';
requires 'Plack::Middleware::Negotiate', '0.06';
requires 'Plack::Middleware::TemplateToolkit', '0.26';
requires 'Plack::App::Directory::Template', '0.26';
requires 'Plack::App::RDF::Files', '0.02';
requires 'Plack::App::GitHub::WebHook', '0.4';

# Git
requires 'Git::Repository';

# Logging
requires 'Log::Contextual', '0.006000';

# Catmandu modules
requires 'Catmandu::RDF', '0.03';
requires 'Catmandu::PICA', '0.01';

requires 'CHI', '0';
requires 'Data::Beacon', '0';
requires 'File::Slurp', '0';
requires 'JSON', '0';
requires 'LWP::Simple', '0';
requires 'PICA::Record', '>= 0.585';

requires 'RDF::Dumper', '0';
requires 'RDF::Flow', '0';
requires 'RDF::Lazy', '0';
requires 'RDF::NS', '0';
requires 'RDF::Trine', '0';
requires 'Try::Tiny', '0';
requires 'Turtle::Writer', '0.004';
requires 'URI', '0';
requires 'URI::Escape', '0';
requires 'experimental';

requires 'Starman';
