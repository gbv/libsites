package GBV::App::Logger;
#ABSTRACT: Import logging methods from Log::Contextual with WarnLogger default

use v5.14.2;
use base 'Log::Contextual';
use Log::Contextual::WarnLogger;

sub arg_default_logger {
    my $package = uc(caller(3));
    $package =~ s/::/_/g;
    Log::Contextual::WarnLogger->new({ env_prefix => $package });
}

sub default_import {
    qw(:dlog :log )
}

1;
