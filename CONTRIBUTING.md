*See `README.md` for general introduction and usage documentation.*

# Infrastructure

## Git repository

The source code of libsites is managed in a public git repository at
<https://github.com/gbv/libsites>.

The latest development is at the `dev` branch. The `master` branch is for
releases only!

## Issue tracker

Bug reports and feature requests are managed as GitHub issues at
<https://github.com/gbv/libsites/issues>.

# Technology

Libsites is mainly written in Perl.

# Development

## First steps

For local usage and development clone the git repository and install
dependencies:

    sudo make dependencies
    make local

Locally run the web application on port 5000 for testing:

    make run

## Sources

Relevant source code is located in

* `app.psgi` - application main script
* `lib/` - application sources (Perl modules)
* `cron.daily` - runs daily to update ./libsites-config
* `cpanfile` - lists required Perl modules
* `public/` - static HTML/CSS/JS/... files
* `bin/` - utility scripts

## Utility scripts

To manually run an update:

    LIBSITES_LOG= perl -Ilib -Ilocal/lib/perl5 bin/update

The `LIBSITES_LOG` environment variable controls where update logs are written
to. Setting it to the empty string, as given above, will log to STDOUT.

## Tests

Run all tests located in directory `t`. 

    make tests

To run a selected test, for instance `t/app.t`: 

    prove -Ilib -Ilocal/lib/perl5

Black-box tests are only run if `TEST_URL` is set to a port number or URL.

# License

libsites is made available under the terms of GNU Affero General Public
License (AGPL).

