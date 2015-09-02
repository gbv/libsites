requires 'perl', '5.14.2';

requires 'Plack::App::GitHub::WebHook', '0.8';
requires 'GitHub::WebHook', '0.11',

requires 'Plack::Middleware::Log::Contextual';
requires 'File::Slurp', '0';

requires 'Unicode::Normalize';

# ???
requires 'Plack::Middleware::Rewrite', '1.0';
requires 'Plack::Middleware::Negotiate', '0.06';
requires 'Plack::Middleware::TemplateToolkit', '0.26';
requires 'Plack::App::Directory::Template', '0.26';
requires 'Plack::App::RDF::Files', '0.12';

# Catmandu modules
requires 'Catmandu', '0.94';            # libcatmandu-perl
requires 'Catmandu::RDF', '0.23';

requires 'RDF::TriN3'; # TODO: move requirement to Catmandu::RDF

requires 'RDF::Lazy', '0';
requires 'Time::Piece', '0';

# requirements met by Debian packages
requires 'Starman';
requires 'RDF::Trine';
requires 'RDF::NS';
requires 'Git::Repository';
requires 'JSON';        
requires 'Log::Contextual', '0.006000';

test_requires 'Plack::Util::Load';
test_requires 'Test::Fatal';
