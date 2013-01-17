Dieses git-Repository enthält öffentliche Standortinformationen von
Bibliotheksstandorten für den Gemeinsamen Bibliotheksverbund (GBV).  Soweit
vorhanden, werden die Informationen nicht direkt im Repository abgelegt
sondern in Form von Skripten, die die Informationen aus anderem Quellen,
z.B. dem ISIL-Verzeichnis, ermitteln.

# Übersicht

Für jede Bibliothek kann im Verzeichnis `isil` ein Unterverzeichnis mit der
jeweiligen Bibliotheks-ISIL angelegt werden. Darin können die Standorte in
einer semi-strukturieren Textdatei `sites.txt` aufgenommen werden, aus der
mittels Makefile strukturierte Standortdaten in JSON-LD und anderen
RDF-Serialisierungen erzeugt werden.

# Aufbau des Repository

Für jede Bibliothek sind folgende Dateien vorgesehen:

* sites.txt - Standortdefinitionen, ggf. mit Name, Adresse, URL, Geokoordinate etc.
  * *sites.json* - RDF/JSON-LD erzeugt aus sites.txt mit `app/txt2json.pl`
  * *sites.nt*   - RDF/Ntriples aus sites.json
* isildir.pica - PICA-Normsatz aus dem ISIL-Verzeichnis, geholt mit `app/getisildir.pl` 
  * *isildir.json* - RDF/JSON-LD erzeugt aus isildirectory.pica mit `app/isildir2rdf.pl`

## Datensätze
## Allgemeine Dateien

* `context.json` - JSON-LD context definition
* `Makefile` 
* `app/txt2json.pl`
* `app/normalize.pl`

# Installation

Das Repository kann direkt von einen Apache-Webserver ausgeliefert werden.
Allerdings sollte im Unterverzeichnis `.git` folgende `.htaccess` angelegt
werden:

    deny from all

Die weitere Steuerung ist bereits in `.htaccess`-Dateien hinterlegt. 

# Requirements

* Make
* Perl >= 5.10.1
* Perl CPAN modules JSON, File::Slurp
* nodejs with package `jsonld`

