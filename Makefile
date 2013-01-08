.SUFFIXES: .txt .json

ALL=$(shell find ./isil -iname sites.txt | sed s/txt/json/)

all: $(ALL)

normalize:
	@find -iname *.json -exec ./bin/normalize.pl '{}' ';'	

.txt.json:
	@echo $< to $@
	@./bin/txt2jsonld.pl $< > $@
	@./bin/normalize.pl $@
