# Standortinformationen für den GBV

Dieses Git-Repository enthält Informationen zu **Bibliotheksstandorten** für
den [Gemeinsamen Bibliotheksverbund](http://www.gbv.de) (GBV). Zu den
Standortinformationen gehören Angaben über Teilbibliotheken oder einzelne
Gebäude, Adressen, Öffnungszeiten, Webseiten etc.

Alle Inhalte sind öffentlich und frei nutzbar im Sinne von Open Data 
([CC Zero](http://creativecommons.org/publicdomain/zero/1.0/deed.de)).

## Übersicht

Im Verzeichnis [`isil`](./isil) kann für jede Bibliothek ein Unterverzeichnis
mit der jeweiligen Bibliotheks-ISIL angelegt werden. Beispielsweise liegen im
Verzeichnis [`isil/DE-Hil2`](./isil/DE-Hil2) die Standortinformationen für die
Universitätsibliothek Hildesheim (ISIL DE-Hil2). Innerhalb der einzelnen
Verzeichnisse sind verschiedene [Quelldateien](#quelldateien) vorgesehen.

Neben dem Verzeichnis `isil` liegen im Verzeichnis [`app`](./app) verschiedene
Programme zur Verwaltung der Standortinformationen.

## Quelldateien 

Soweit vorhanden, werden die Informationen nicht direkt im Repository abgelegt
sondern in Form von Skripten, die die Informationen aus anderem Quellen, z.B.
dem ISIL-Verzeichnis, ermitteln.

Für jede Bibliothek sind folgende Dateien vorgesehen:

* sites.txt - Standortdefinitionen, ggf. mit Name, Adresse, URL, Geokoordinate etc.
  * *sites.json* - RDF/JSON-LD erzeugt aus sites.txt mit `app/txt2json.pl`
  * *sites.nt*   - RDF/Ntriples aus sites.json
* zdb.pica - PICA-Normsatz aus dem ISIL-Verzeichnis, geholt mit `app/getzdb.pl` 
  * *zdb.json* - RDF/JSON-LD erzeugt aus zdb.pica mit `app/isildir2rdf.pl`
  * *zdb.ttl* - RDF/Turtle-Version
* zdbrdf.nt - RDF-Export aus dem ISIL-Verzeichnis
* lobid.ttl - RDF/Turtle von Lobid.org
* opac.ttl - Informationen zum Katalog der Bibliothek, geholt mit `app/getopac.pl`

## Installation

Das Repository kann direkt von einen Apache-Webserver ausgeliefert werden.
Allerdings sollte im Unterverzeichnis `.git` folgende `.htaccess` angelegt
werden:

    deny from all

Die weitere Steuerung ist bereits in `.htaccess`-Dateien hinterlegt. 

## Requirements

* Make
* Perl >= 5.14
* Perl CPAN modules
  * JSON
  * File::Slurp
  * PICA::Record >= 0.584
  * RDF::NS
  * RDF::Lazy
  * RDF::Trine
  * Plack::Middleware::TemplateToolkit
  * CHI
* nodejs with package `jsonld` (TODO: entfernen)
  * `sudo aptitude install nodejs npm`
  * `cd app`
  * `npm install jsonld`

