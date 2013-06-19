# Bibliotheksverzeichnis als Linked Open Data für den GBV

Diese Git-Repository enthält **Informationen zu Bibliotheken und verwandten
Einrichtungen** für den [Gemeinsamen Bibliotheksverbund](http://www.gbv.de)
(GBV). Zu den Informationen Angaben wie Namen, Adressen, Öffnungszeiten,
Standorte, Teilbibliotheken etc. Prinzipiell werden nur solche Daten
aufgenommen, die nicht automatisch aus anderen Quellen, wie dem
[ISIL-Verzeichnis](http://sigel.staatsbibliothek-berlin.de/) ermittelt
werden können.

Die Inhalte werden unter <http://uri.gbv.de/organization/> als Linked Open
Data zur Verfügung gestellt und sind frei nutzbar im Sinne von Open Data
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
  * *sites.ttl* - RDF/Turtle erzeugt aus sites.txt mit `app/txt2ttl.pl`
* zdb.pica - PICA-Normsatz aus dem ISIL-Verzeichnis, geholt mit `app/getzdb.pl` 
  * *zdb.ttl* - RDF/Turtle erzeugt aus zdb.pica mit `app/zdb2ttl.pl`
* zdbrdf.nt - RDF-Export aus dem ISIL-Verzeichnis
* lobid.ttl - RDF/Turtle von Lobid.org
* opac.ttl - Informationen zum Katalog der Bibliothek, geholt von
   <http://uri.gbv.de/database/> mit `app/getopac.pl`

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
  * `sudo aptitude install node npm`
  * `cd app`
  * `npm install jsonld`

