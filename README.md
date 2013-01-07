Dieses git-Repository enthält öffentliche Standortinformationen von
Bibliotheksstandorten für den Gemeinsamen Bibliotheksverbund (GBV).

# Übersicht

Für jede Bibliothek kann im Verzeichnis `isil` ein Unterverzeichnis mit der
jeweiligen Bibliotheks-ISIL angelegt werden. Darin können die Standorte in
einer semi-strukturieren Textdatei `sites.txt` aufgenommen werden, aus der
mittels Makefile strukturierte Standortdaten in JSON-LD erzeugt werden.

# Aufbau des Repository

Das Repository kann direkt von einen Apache-Webserver ausgeliefert werden.
Allerdings sollte im Unterverzeichnis `.git` folgende `.htaccess` angelegt
werden:

    deny from all

Die weitere Steuerung ist bereits in `.htaccess`-Dateien hinterlegt. 

* `context.json` - JSON-LD context definition
* `Makefile` 
* `bin/txt2json.pl`
* `bin/normalize.pl`

# Requirements

* Make
* Perl >= 5.10.1
* Perl CPAN modules JSON, File::Slurp

