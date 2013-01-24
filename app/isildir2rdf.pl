#!/usr/bin/perl
#ABSTRACT: Konvertiert ISIL-Verzeichnis in PICA+ nach RDF/JSON-LD
use v5.14;
use autodie;
use JSON;

use PICA::Parser;

# Zur Dokumentation des PICA+ Format des ISIL-Verzeichnis siehe
# http://sigel.staatsbibliothek-berlin.de/vergabe/adressenformat/

binmode \*STDOUT, 'utf8';

sub grepsf {
    my ($p, $m) = @_;
    die "bad format: $m" if $m !~ /^(\d\d\d[A-Z@])\$(.)\[(.)=(.+)\]$/;
    my ($f, $s, $t, $v) = ($1, $2, $3, $4);
    map { $_->sf($s) } grep { $_->sf($t) eq $v } $p->field($f);
}

PICA::Parser->new->parsefile( \*STDIN, Record => sub {
    my $p = shift;

    my ($isil)  = $p->sf('008H$e') or return;
    my @moreisil = split /\s*;\s*/, $p->sf('008H$h');

    my $rdf = {
        '@id' => "http://uri.gbv.de/organization/isil/$isil",
        'dc:identifier' => (@moreisil ? [ $isil, @moreisil ] : $isil ),
        'rdf:type' => [ 'daia:Institution', 'frbr:CorporateBody', 'foaf:Organization' ],
        'owl:sameAs' => "http://lobid.org/organisation/$isil", 
    };

    ($rdf->{'foaf:name'})   = $p->sf('029A$a');
    ($rdf->{'dbprop:shortName'}) = grepsf($p,'029@$a[4=c]');

    my ($adr) = grep { $_->sf('p') ~~ 'j' and $_->sf('2') ~~ 'S' } $p->field('032P');
    if ($adr) {
        my ($a,$b,$d,$e,$k,$l,$i) = map { $adr->sf($_) } qw(a b d e k l i);
        if ($k && $l) {
            $rdf->{'geo:location'} = { 'geo:lat' => $l, 'geo:long' => $k };
        }
        $rdf->{'gbv:address'} = "$a\n$e $b";
        # TODO: Ländercode in $d
        $rdf->{'gbv:openinghours'} = $i;
    }

    my ($com) = grep { $_->sf('c') ~~ 'j' && $_->sf('a') ~~ 'S' } $p->field('035B');
    if ($com) {
        my ($d,$e,$f) = map { $com->sf($_) } qw(d e f);
        my $tel = "(+$d)-$e/$f";
        ($rdf->{'foaf:phone'}) = "tel:+$tel" if $tel =~ /^[0-9()\/ -]+$/;
        $rdf->{'foaf:mbox'} = $rdf->{'vcard:email'} = $com->sf('k');
    }
    
    # TODO
    # dc:description = ... (?)

    # 029R$9 : PPN der übergeordneten Einrichtung
    # 035E$f : Typ der Einrichtung
    # 035E$g : Unterhaltsträger
    # 035D$b : ehem. ISIL übernommener Einrichtung
    # 035I$a : Leihverkehrsregion
    # 035I$c : Verbundsystem

    ($rdf->{'vcard:url'})   = grepsf($p,'009Q$u[z=A]');
    $rdf->{'foaf:homepage'} = $rdf->{'vcard:url'};

    delete $rdf->{$_} for grep { !defined $rdf->{$_} } keys %$rdf;
    print_jsonld( $rdf );
} );

sub print_jsonld {
    my $rdf = shift;
    my $jsonld = { '@graph' => [ $rdf ] };
    print to_json( $jsonld, { pretty => 1, canonical => 1 } );
}

