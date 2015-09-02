use strict;
use Test::More;
use Plack::Test;
use Plack::Util;
use Plack::Util::Load;
use HTTP::Request::Common;
use JSON;

plan skip_all => 'whitebox test' if $ENV{TEST_URL};

$ENV{LIBSITES_CONFIG} = 't/config';

my $app = load_app('app.psgi');

test_psgi $app, sub {
    my $cb = shift;

    my $res = $cb->(GET "/isil/DE-Ilm1");
    is $res->code, 200, 'found DE-Ilm1';

    $res = $cb->(GET "/isil/DE-Ilm1?format=json");
    is $res->code, 200;

    my $rdf = decode_json($res->decoded_content);

    is_deeply $rdf, {
       'http://uri.gbv.de/database/opac-de-ilm1' => {
         'http://purl.org/dc/elements/1.1/subject' => [
           {
             'type' => 'uri',
             'value' => 'http://uri.gbv.de/database/opac'
           }
         ],
         'http://purl.org/dc/terms/title' => [
           {
             'type' => 'literal',
             'value' => "Katalog der Universit\x{e4}tsbibliothek Ilmenau"
           }
         ],
         'http://purl.org/ontology/gbv/dbkey' => [
           {
             'type' => 'literal',
             'value' => 'opac-de-ilm1'
           }
         ]
       },
       'http://uri.gbv.de/organization/isil/DE-Ilm1' => {
         'http://purl.org/ontology/gbv/opac' => [
           {
             'type' => 'uri',
             'value' => 'http://uri.gbv.de/database/opac-de-ilm1'
           }
         ],
         'http://xmlns.com/foaf/0.1/name' => [
           {
             'type' => 'literal',
             'value' => "Universit\x{e4}tsbibliothek Ilmenau"
           }
         ]
       }
     };
};

done_testing;
