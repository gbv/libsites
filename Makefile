APP=bin/app.psgi
LIB=perl5/lib/perl5
CARTON=perl5/bin/carton

deps:
	@if [ "$$PERLBREW_PERL" ]; then\
		cpanm --installdeps . ;\
	else \
		[ -f $(CARTON) ] || cpanm -L perl5 Carton ;\
		perl -I$(LIB) $(CARTON) install ;\
	fi

build: noperlbrew deps
	@echo "Make sure to have no perlbrew-installed libs in perl5/!"
	@makedpkg

test:
	@perl -I$(LIB) $(CARTON) exec -- prove -Ilib t

debug:
	@perl -I$(LIB) $(CARTON) exec -- perl5/bin/plackup -R lib -r $(APP)

start:
	@perl -I$(LIB) $(CARTON) exec -- perl5/bin/starman $(APP)

noperlbrew:
	@if [ "$$PERLBREW_PERL" ]; then\
	 	echo "please switch off perlbrew for build!" ;\
		exit 1 ;\
	fi

clean:
	@rm -rf debuild cache

purge: clean
	@rm -rf perl5

.PHONY: doc deps build test start noperlbrew update

doc:
	@cd ../doc; make html pdf

