#!/usr/bin/env perl
#ABSTRACT: Konvertiert ISIL-Verzeichnis in PICA+ nach RDF/Turtle
use v5.14;
use autodie;
use JSON;

use PICA::Parser;
use Turtle::Writer;
use RDF::NS;

# Zur Dokumentation des PICA+ Format des ISIL-Verzeichnis siehe
# http://sigel.staatsbibliothek-berlin.de/vergabe/adressenformat/

binmode \*STDOUT, 'utf8';

say $_ for RDF::NS->new->TTL(qw(foaf dc gbv org geo owl dbprop vcard rdf daia frbr));

sub grepsf {
    my ($p, $m) = @_;
    die "bad format: $m" if $m !~ /^(\d\d\d[A-Z@])\$(.)\[(.)=(.+)\]$/;
    my ($f, $s, $t, $v) = ($1, $2, $3, $4);
    map { $_->sf($s) } grep { $_->sf($t) eq $v } $p->field($f);
}

PICA::Parser->new->parsefile( $ARGV[0], Record => sub {
    my $p = shift;

    my ($isil)  = $p->sf('008H$e') or return;
    my @moreisil = split /\s*;\s*/, $p->sf('008H$h');

    my $rdf = {
        '@id' => "http://uri.gbv.de/organization/isil/$isil",
        'dc:identifier' => ( @moreisil ?
            [ map { turtle_literal($_) } $isil, @moreisil ]
              : turtle_literal($isil) 
        ),
        'rdf:type' => [ 'daia:Institution', 'frbr:CorporateBody', 'foaf:Organization' ],
        'owl:sameAs' => "<http://lobid.org/organisation/$isil>", 
    };

    ($rdf->{'foaf:name'}) = map { turtle_literal($_) } $p->sf('029A$a');
    ($rdf->{'dbprop:shortName'}) = map { turtle_literal($_) } grepsf($p,'029@$a[4=c]');

    my ($adr) = grep { $_->sf('p') ~~ 'j' and $_->sf('2') ~~ 'S' } $p->field('032P');
    if ($adr) {
        my ($a,$b,$d,$e,$k,$l,$i) = map { $adr->sf($_) } qw(a b d e k l i);
        if ($k && $l) {
            $rdf->{'geo:location'} = { 'geo:lat' => $l, 'geo:long' => $k };
        }
        $rdf->{'gbv:address'} = turtle_literal("$a\n$e $b");
        # TODO: Ländercode in $d
        $rdf->{'gbv:openinghours'} = turtle_literal($i);
    }

    my ($com) = grep { $_->sf('c') ~~ 'j' && $_->sf('a') ~~ 'S' } $p->field('035B');
    if ($com) {
        my ($d,$e,$f) = map { $com->sf($_) } qw(d e f);
        my $tel = "(+$d)-$e/$f";
        ($rdf->{'foaf:phone'}) = "<tel:+$tel>" if $tel =~ /^[0-9()\/ -]+$/;
        $rdf->{'foaf:mbox'} = $rdf->{'vcard:email'} = "<mailto:".$com->sf('k').">";
    }
    
    # TODO
    # dc:description = ... (?)

    # 029R$9 : PPN der übergeordneten Einrichtung
    # 035E$f : Typ der Einrichtung
    # 035E$g : Unterhaltsträger
    # 035D$b : ehem. ISIL übernommener Einrichtung
    # 035I$a : Leihverkehrsregion
    # 035I$c : Verbundsystem

    ($rdf->{'vcard:url'})   = map { "<$_>" } grepsf($p,'009Q$u[z=A]');
    $rdf->{'foaf:homepage'} = $rdf->{'vcard:url'};

    delete $rdf->{$_} for grep { !defined $rdf->{$_} } keys %$rdf;

    print_turtle( $rdf );
} );

sub print_turtle {
    my $rdf = shift;
    my $uri = delete $rdf->{'@id'};
    say turtle_statement( "<$uri>" , %$rdf );
}

