.PHONY: info zdb zdbttl lobid opac update sites isil.csv
.SUFFIXES: .txt .pica .nt .ttl

PICA = $(shell find isil -name '*.pica')
TXT  = $(shell find isil -name '*.txt')
PICATTL = $(shell find isil -name '*.pica' | sed s/pica/ttl/)
TXTTTL = $(shell find isil -name '*.txt' | sed s/txt/ttl/)

info:
	@find isil/* -mindepth 1 -printf '%f\n' | sort | uniq -c
	@find isil/* -type d -empty

sites: $(TXTTTL)

zdbttl: $(PICATTL)

zdb: getzdb zdbttl

getzdb:
	@ls ./isil | xargs ./app/getzdb.pl
	
lobid:
	@ls ./isil | xargs ./app/getlobid.pl

opacs:
	@ls ./isil | xargs ./app/getopac.pl

update: zdb lobid opacs sites
	
###############################################################################
# Create Turtle from PICA

.pica.ttl:
	@echo $< to $@
	@./app/zdb2ttl.pl $< > $@

###############################################################################
# Create Turtle from TXT

.txt.ttl:
	@echo $< to $@
	@./app/txt2ttl.pl $< > $@

###############################################################################
# Extract from RDF (TODO: CREATE BEACON FILE)
# ...
###############################################################################

isil.csv:
	@ls isil > $@	

###############################################################################

clean:
	@find isil -o -iname *.nt -o -iname *.pica -exec rm '{}' ';'

