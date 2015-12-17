TITLE   = VZG-Standortverzeichnis
AUTHOR  = Jakob Voß, Verbundzentrale des GBV
NAME    = libsites

libsites.md: ../README.md ../debian/changelog
	sed -r 's!^See `debian/changelog`.!./changelog2markdown!e' ../README.md > $@

include vzgspec/Makefile

LANGUAGE=ngerman
