.PHONY: info isildir lobid shortnames
.SUFFIXES: .txt .pica .json .nt

TXT =$(shell find isil -name '*.txt')
PICA=$(shell find isil -name '*.pica')
JSON=$(shell find isil -name '*.txt' -o -name '*.pica' | sed s/pica/json/ | sed s/txt/json/)
NT  =$(shell find isil -name '*.json' | sed s/json/nt/)

info:
	@find isil/* -mindepth 1 -printf '%f\n' | sort | uniq -c
	@find isil/* -type d -empty

isildir:
	@ls ./isil | xargs ./app/getisildir.pl
	
lobid:
	@ls ./isil | xargs ./app/getlobidorg.pl

opacs:
	@ls ./isil | xargs ./app/getopac.pl

# convert all .txt and .pica to .json
json: $(JSON)

###############################################################################
# Create JSON-LD from PICA

.pica.json:
	@echo $< to $@
	@./app/isildir2rdf.pl < $< > $@
	@./app/normalize.pl $@

###############################################################################
# Create JSON-LD from TXT

.txt.json:
	@echo $< to $@
	@./app/txt2jsonld.pl $< > $@
	@./app/normalize.pl $@

###############################################################################
# Create N-Triples from JSON-LD

nt: $(NT)

.json.nt:
	@echo $< to $@
	@node app/jsonld2nt.js $< context.json > $@

###############################################################################
# Extract from RDF

shortnames: $(NT)
	@grep -r short isil/*/*.nt
# TODO: nt2beacon

###############################################################################

clean:
	@find isil -iname *.json -o -iname *.nt -o -iname *.pica -exec rm '{}' ';'

normalize:
	@find -iname *.json -exec ./app/normalize.pl '{}' ';'	

