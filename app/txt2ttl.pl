#!/usr/bin/perl
#ABSTRACT: Parse library sites information and convert to JSON-LD

use strict;
use v5.14;
use autodie;
use JSON;
use Turtle::Writer;
use RDF::NS;

my $sites = { };
my %tels = ();
my (%cur, $address, $hours, $info, $sep);
my $isil = "";

my $ISIL = qr{([A-Z]+-[A-Za-z0-9-]+)};

if (@ARGV and $ARGV[0] =~ $ISIL) {
    $isil = $1;
}

sub fail($) { 
    say STDERR "line $.: ".shift; exit 1; 
}

sub finish {
    return unless %cur;
    $cur{'gbv:openinghours'} = turtle_literal($hours) if $hours;
    if (!$info and $address and $address !~ /\d/m) {
        $info = $address; 
        $address = "";
    }
    $cur{'gbv:address'} = turtle_literal($address) if $address;
    $cur{'dc:description'} = turtle_literal($info) if $info;

    my $sst = $cur{'@id'};
    $sites->{ $sst } = { %cur };
    ($address, $hours, $info, $sep, %cur) = ("","","",0,()); 
    delete $cur{'foaf:name'};
}

my $ISIL = '[A-Z]{2}-[A-Za-z0-9-]{1,11}';

while(<>) {
    s/^\s+|\s+$//g;
    next if /^#/; # comment

    if ($_ and $_ =~ qr{^($ISIL)?(@(.*))?$}) {
        my $sst = $1 // $isil // fail "Missing ISIL for identifier: $_";
        $sst = "http://uri.gbv.de/organization/isil/$sst" . ($3 ? $2 : '');
        finish;
        $cur{'@id'} = $sst;
    } elsif (!$cur{'foaf:name'}) {
        $cur{'foaf:name'} = turtle_literal($_);
    } elsif ($_ =~ qr{[^@ ]+@[^@ ]+$}) {
        $cur{'foaf:mbox'} = "<mailto:$_>";
        $sep=1;
    } elsif ($_ =~ qr{^http://.+$}) {
        $cur{'foaf:homepage'} = "<$_>";
        $sep=1;
    } elsif ($_ =~ qr{^(\d+\.\d+)\s*[,/;]\s*(\d+\.\d+)$}) {
        $cur{'geo:location'} = { 'geo:lat' => $1, 'geo:long' => $2 };
        $sep=1;
    } elsif ($_ =~ qr{^(\+|\(\+)[0-9\(\)/ -]+$}) {
        my $tel = $_;
        $tel =~ s/\s+/-/g;
        $cur{'foaf:phone'} = "<tel:$tel>";
        $tels{ "tel:$tel" } = { "rdf:value" => turtle_literal($tel) };
        $sep=1;
    } elsif ($_ =~ qr{(\d\d:\d\d|Uhr)} and $_ =~ qr{(Mo|Di|Mi|Do|Fr|Sa|So)}) {
        $hours = $hours ? "$hours\n$_" : $_;
        $sep=1;
    } elsif( !$_ ) {
        $sep=1;
    } else {
        if ($sep) {
            $info = $info ? "$info\n$_" : $_;
        } else {
            $address = $address ? "$address\n$_" : $_;
        }
    }
}
finish;

delete $_->{'@id'} for values %$sites;

if ($isil) {
    $isil = "http://uri.gbv.de/organization/isil/$isil";
    my @has = map { "<$_>" } grep { $_ ne $isil && $_ ne "" } keys %$sites;
    $sites->{$isil}->{'org:hasSite'} = \@has if @has;
}

say $_ for (RDF::NS->new->TTL(qw(foaf dc gbv org geo rdf)),'');

foreach (keys %$sites) {
    say turtle_statement("<$_>",
        %{ $sites->{$_} }
    );
}

say turtle_statement("<$_>", %{$tels{$_}}) for keys %tels;

