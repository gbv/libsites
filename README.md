Dieses git-Repository enthält Standortinformationen von Bibliotheksstandorten.

# Übersicht

Für jede Bibliothek kann im Verzeichnis `isil` ein Unterverzeichnis mit der
jeweiligen Bibliotheks-ISIL angelegt werden. Darin können die Standorte in
einer semi-strukturieren Textdatei `sites.txt` aufgenommen werden, aus der
mittels Makefile strukturierte Standortdaten in JSON-LD erzeugt werden.

# Additional files

* `context.json` - JSON-LD context definition
* `Makefile` 
* `bin/txt2json.pl`
* `bin/normalize.pl`

# Requirements

* Make
* Perl >= 5.10.1
* Perl CPAN modules JSON, File::Slurp

