#!/usr/bin/env perl
#ABSTRACT: Holt PICA+ und RDF-Daten aus dem ISIL-Verzeichnis
use v5.14;

use FindBin;
use lib "./lib";
use GBV::App::GetISIL;

use PICA::Source;
use Encode;

my $sru = PICA::Source->new( SRU => 'http://sru.gbv.de/isil' );
my $zdbbase = "http://ld.zdb-services.de/resource/organisations/";
my $gbvbase = "http://uri.gbv.de/organization/isil/";

getisil( 
    'zdb.pica' => sub {
        my $isil = shift;
        my ($pica) = $sru->cqlQuery("pica.isi=$isil")->records();
        return unless $pica and $pica->sf('008H$e') eq $isil;
        $pica = encode('UTF-8',decode('ISO-8859-1',"$pica"));
        return $pica;
    }, 'zdbrdf.nt' => sub {
        my $isil = shift;
        
        # TODO: use RDF::Trine
        # my ($rdf, $msg) = getlod( $url );
        # return (undef, $msg) unless $rdf;

        my $nt = `rapper $zdbbase$isil -o ntriples`;
        if ($nt) {
            $nt =~ s{$zdbbase$isil}{$gbvbase$isil}mg;
            $nt =~ s{"\(ISIL\)([^"]+)"}{"\1"}mg;
            $nt .= "<$zdbbase$isil> <http://www.w3.org/2002/07/owl#sameAs> <$gbvbase$isil> .\n";
        }
        
        return ($nt);
});
