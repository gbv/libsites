APP=bin/app.psgi

deps:
	@if [ "$$PERLBREW_PERL" ]; then\
		cpanm --installdeps . ;\
	else \
		[ -f local/bin/carton ] || cpanm -L local Carton ;\
		perl -Ilocal/lib/perl5 local/bin/carton install ;\
	fi

build: noperlbrew deps
	@echo "Make sure to have no perlbrew-installed libs in local/!"
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

.PHONY: doc deps build test start noperlbrew update

doc:
	@cd ../doc; make html pdf

########################################################################

LIBSITES_CONFIG = ./libsites-config

ISILS	        = $(LIBSITES_CONFIG)/isil

.SUFFIXES: .txt .pica .nt .ttl

PICA    = $(shell find $(ISILS) -name '*.pica')
TXT     = $(shell find $(ISILS) -name '*.txt')
PICATTL = $(shell find $(ISILS) -name '*.pica' | sed s/pica/ttl/)

.pica.ttl:
	@echo $< to $@
	@./bin/zdb2ttl.pl $< > $@

zdbttl: $(PICATTL)

zdb: getzdb zdbttl

getzdb:
		@ls $(ISILS) | xargs ./bin/getzdb.pl
			
lobid:
		@ls $(ISILS) | xargs ./bin/getlobid.pl

opacs:
		@ls $(ISILS) | xargs ./bin/getopac.pl

update: dirs zdb lobid opacs sites

sites:
	@make -C $(LIBSITES_CONFIG) sites

clean-isil:
	@cd $(LIBSITES_CONFIG) && make clean

