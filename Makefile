# install required Perl packages
local: cpanfile
	cpanm -l local --skip-satisfied --installdeps --notest .

# run locally
run: local
	plackup -Ilib -Ilocal/lib/perl5 -r app.psgi

# check sources for syntax errors
code:
	@find lib -iname '*.pm' -exec perl -c -Ilib -Ilocal/lib/perl5 {} \;

# run tests
tests: local
	PLACK_ENV=tests prove -Ilocal/lib/perl5 -l -v
