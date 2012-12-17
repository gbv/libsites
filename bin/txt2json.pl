#!/usr/bin/perl
#ABSTRACT: Parse library sites information and convert to JSON-LD

use strict;
use v5.10.1;
use autodie;
use JSON;

my $sites = { };
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
    $cur{'gbv:openinghours'} = $hours if $hours;
    if (!$info and $address and $address !~ /\d/m) {
        $info = $address; 
        $address = "";
    }
    $cur{'gbv:address'} = $address if $address;
    $cur{'dc:description'} = $info if $info;

    my $sst = $cur{'@id'};
    $sites->{ $sst } = { %cur };
    ($address, $hours, $info, $sep, %cur) = ("","","",0); 
}

while(<>) {
    s/^\s+|\s+$//g;

    if ($_ and $_ =~ qr{^([A-Z]+-[A-Za-z0-9-]+)?(@(.*))?$}) {
        my $sst = $1 // $isil // fail "Missing ISIL for identifier: $_";
        $sst = "http://uri.gbv.de/organization/isil/$sst";
        if ($3) {
            $sst .= $2;
        }
        finish;
        $cur{'@id'} = $sst;
    } elsif (!$cur{'foaf:name'}) {
        $cur{'foaf:name'} = $_;
    } elsif ($_ =~ qr{[^@ ]+@[^@ ]+$}) {
        $cur{'foaf:mbox'} = "mailto:$_";
        $sep=1;
    } elsif ($_ =~ qr{^http://.+$}) {
        $cur{'foaf:homepage'} = $_;
        $sep=1;
    } elsif ($_ =~ qr{^(\d+\.\d+)\s*[,/;]\s*(\d+\.\d+)$}) {
        $cur{'geo:location'} = { 'geo:lat' => $1, 'geo:long' => $2 };
        $sep=1;
    } elsif ($_ =~ qr{^(\+|\(\+)[0-9\(\)/ -]+$}) {
        my $tel = $_;
        $tel =~ s/\s+/-/g;
        $cur{'foaf:phone'} = "tel:$tel";
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

if ($isil) {
    $isil = "http://uri.gbv.de/organization/isil/$isil";
    $sites->{$isil} //= { '@id' => $isil };
    my @has = grep { $_ ne $isil } keys %$sites;
    $sites->{$isil}->{'org:hasSite'} = \@has if @has;
}

my $json = to_json($sites, {pretty=>1, canonical=>1});

print $json;


