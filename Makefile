APP=app.psgi

deps:
	@if [ "$$PERLBREW_PERL" ]; then\
		cpanm --installdeps . ;\
	else \
		[ -f local/bin/carton ] || cpanm -L local Carton ;\
		perl -Ilocal/lib/perl5 local/bin/carton install ;\
	fi

build: noperlbrew deps
	@./makedpkg

test:
	@if [ "$$PERLBREW_PERL" ]; then\
		prove -Ilib t ;\
	else\
		perl -Ilocal/lib/perl5 local/bin/carton exec -- prove -Ilib t ;\
	fi

start:
	@if [ "$$PERLBREW_PERL" ]; then\
		plackup -Ilib $(APP) ;\
	else \
		perl -Ilocal/lib/perl5 local/bin/carton exec -- local/bin/starman $(APP) ;\
	fi

noperlbrew:
	@if [ "$$PERLBREW_PERL" ]; then\
	 	echo "please switch off perlbrew for build!" ;\
		exit 1 ;\
	fi

clean:
	@rm -rf debuild cache

purge: clean
	@rm -rf local

.PHONY: doc deps build test start noperlbrew

doc:
	@cd ../doc; make html pdf

