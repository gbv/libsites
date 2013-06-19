#!/usr/bin/perl

use v5.14;
use autodie;
use File::Slurp;
use JSON;

my $file = shift @ARGV;
my $from = read_file($file);
my $json = to_json(from_json($from), {pretty=>1, canonical=>1});

if ($from ne $json) {
    write_file( $file, $json );
    say "normalized $file";
}
