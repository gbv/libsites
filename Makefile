deps:
	@carton install --deployment

test:
	@carton exec -- prove -Ilib t

#debian: clean deps
#	@dzil debuild --uc --us

doc:
	@cd ../doc; make html pdf

# start in development mode
run:
	@exec carton exec -- plackup -r -Ilib

clean:
	@rm -rf cover_db debuild cache

.PHONY: deps test run debian cover doc clean
