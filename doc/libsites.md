# Übersicht
 
Die **VZG-Standortverwaltung** ("libsites") ist eine Webanwendung zur
Aggregation und Präsentation von Informationen über Bibliotheken, Museen und
verwandte Einrichtungen, soweit diese für die Anwendungen der VZG relevant
sind. Die zusammengeführen Informationen wie Namen, Adressen, Öffnungszeiten,
Teilbibliotheken etc. stehen unter <http://uri.gbv.de/organization/> als Linked
Open Data ([CC Zero]) zur Verfügung.

[CC Zero]: http://creativecommons.org/publicdomain/zero/1.0/deed.de

## Inhalte der Standortverwaltung

Grundsätzlich ist die VZG-Standortverwaltung so konzipiert, dass möglichst alle
Informationen automatisch aus vorhandenen Quellen ermittelt werde. So stammen
bspw. die wesentlichen Stammdaten zu Bibliotheken aus dem  [ISIL- und
Sigelverzeichnis](http://zdb-opac.de/DB=1.2). Ergänzungen und Änderungen werden
deshalb nicht direkt in die Standortverwaltung eingetragen sondern müssen in
der jeweiligen Datenquelle vorgenommen werden. Lediglich *zusätzliche*
Informationen, für die keine eigene Datenbank oder andere Informationsquelle
existiert, werden direkt in der [Konfiguration] der Standortverwaltung
("libsites-config") eingetragen. Im Wesentlichen handelt es sich dabei um
Informationen zu untergeordneten [Standorten](#definition-von-standorten).

Alle in der Standortverwaltung berücksichtigten Einrichtungen müssen eindeutig
durch einen International Standard Identifier for Libraries and Related
Organisations (ISIL) identifizierbar sein oder sich genau einer Organisation
mit ISIL zuordnen lassen. Im Zweifelsfall ist zunächst ein Eintrag bei der
nationalen ISIL-Stelle zu beantragen. Dies gilt auch für übergeordnete Einträge
zum Zusammenfassen mehrerer bereits vorhandener Einrichtungen.

## Abruf von Standortinformationen

Alle Inhalte der VZG-Standortverwaltung sind frei (als [CC Zero]) unter
<http://uri.gbv.de/organization/> abrufbar. Der Abruf von Informationen zu
einer ausgewählten Einrichtung ist über die URI der jeweiligen Einrichtung
möglich. Die URI ergibt sich durch aus dem ISIL (und ggf. Standortkürzel) 
durch Voranstellen von <http://uri.gbv.de/organization/isil/>.

Das Datenformat kann per HTTP-Content-Negotiation oder mit dem URL-Parameter
`format` gewählt werden. Statt als GET-Parameter kann das Format der URL
auch getrennt durch einen Punkt angefügt werden. Die folgenden drei Anfragen
rufen jeweils die Standortinformationen der UB Hildesheim ab:

    curl -H "Accept: text/turtle" http://uri.gbv.de/organization/isil/DE-Hil2
    curl 'http://uri.gbv.de/organization/isil/DE-Hil2?format=ttl'
    curl http://uri.gbv.de/organization/isil/DE-Hil2.ttl

Grundsätzlich werden folgende Formate unterstützt:

 format   MIME type
-------- --------------------- -----------------------
 html     text/html             HTML (standard)
 rdf      application/rdf+xml   RDF/XML (TODO!)
 ttl      text/turtle           RDF/Turtle
 nt       text/plain            NTriples
 n3       text/n3               NTriples
 json     application/rdf+json  RDF/JSON
-------- --------------------- -----------------------

Zusätzlich zum Abruf einzelner Einrichtungen und Standorte ist eine
Download-Möglichkeit unter <http://uri.gbv.de/organization/download/> geplant. 

<!--
## Interpretation der Standortinformationen

TODO
-->

<!-- TODO: Skript und/oder Webapi zum Parsen und Überprüfen -->

## Überprüfung der Konfiguration

Unter <http://uri.gbv.de/organization/config> kann der aktuelle Stand der
Konfiguration in der laufenden Webanwendung eingesehen und überprüft werden.
Die Verzeichnisse enthalten zusätzlich temporäre Dateien (siehe
[Datenquellen](#datenquellen)].

# Installation und Administration

[Installation]: #installation-und-administration

Die Webanwendung der VZG-Standortverwaltung wird in einem git-Repository
verwaltet, das auf GitHub unter <https://github.com/gbv/libsites> einsehbar
ist. Für Installation und Updates wird aus dem Quelltext der Anwendung ein
Debian-Paket erstellt, das sich auf einem beliebigen Produktiv- oder Testsystem
mit gleicher Systemarchitektur installieren lässt. Die Webanwendung ist
möglichst mit [Unit-Tests](#unit-tests) abgedeckt, die bei einem Push nach
GitHub automatisch unter <https://travis-ci.org/gbv/libsites> ausgeführt
werden.

## Datenquellen

Für jede Bibliothek sind folgende Dateien vorgesehen:

* sites.txt - Standortdefinitionen, ggf. mit Name, Adresse, URL, Geokoordinate etc.
  * *sites.ttl* - RDF/Turtle erzeugt aus sites.txt mit `app/txt2ttl.pl`
* zdb.pica - PICA-Normsatz aus dem ISIL-Verzeichnis, geholt mit `app/getzdb.pl` 
  * *zdb.ttl* - RDF/Turtle erzeugt aus zdb.pica mit `app/zdb2ttl.pl`
* zdbrdf.nt - RDF-Export aus dem ISIL-Verzeichnis
* lobid.ttl - RDF/Turtle von Lobid.org
* opac.ttl - Informationen zum Katalog der Bibliothek, geholt von
   <http://uri.gbv.de/database/> mit `app/getopac.pl`

## Updates der Konfiguration

# Software-Entwicklung

Die Webanwendung ist in Perl (ab Version 5.14.2) geschrieben und basiert u.A.
auf [Plack], [Moo] und [Catmandu]. Zur Verwaltung der benötigten CPAN-Module
wird [Carton] verwendet. 

[Plack]: https://metacpan.org/module/Plack
[Moo]: https://metacpan.org/module/Moo
[Carton]: https://metacpan.org/module/Carton
[Catmandu]: https://metacpan.org/module/Catmandu

## Datei-Übersicht

Im Wurzelverzeichnis befinden sich folgende Dateien und Unterverzeichnisse:

    |-- app.psgi             Plack/PSGI Start-Datei
    |-- catmandu             Hilfs-Skript zum Ausführen von Catmandu mit Carton
    |-- cpanfile             Benötigte CPAN-Module
    |-- cpanfile.snapshot    Genau verwendete CPAN-Module
    |-- config/              Konfigurationsdateien zur Installation
    |-- doc/                 Dieses Handbuch
    |-- root/                Statische Dateien und Templates (HTML, CSS, ...)
    |-- lib/                 Perl-Module der Webanwendung
    |-- Makefile             Makefile 
    |-- start                Skript zum Starten der Webanwendung mit Starman
    |-- t/                   Unit-Tests
    |-- test                 Skript zum Aufrufen der Unit-Tests
    \-- .travis.yml          Konfigurationsdatei für CI-Tests auf travis-ci.org


## Modul-Übersicht

GBV::App::Libsites
  : Webanwendung, wird von `app.psgi` aufgerufen.

GBV::App::Libsites::Parser
  : Parser für `sites.txt` Format.

Catmandu::Importer::Libsites
  : Aktiviert `GBV::App::Libsites::Parser` als Importer in [Catmandu]:

        ./catmandu convert libsites to YAML < sites.txt

# Voraussetzungen

Zur Weiterentwicklung der Webanwendung werden benötigt:

* Grundlegende Build-Tools (GNU make, C-Compiler etc.)
* Debian-Paket-Tools (devscripts und debhelper)
* git
* Perl (mind. 5.14)
* [Carton] (mind. 1.0) und cpanm (mind. 1.6)

Die benötigten Programme lassen sich unter Ubuntu folgendermaßen installieren:

    sudo apt-get install build-essential devscripts debhelper git-core perl
    wget -O - http://cpanmin.us | sudo perl - --self-upgrade
    sudo cpanm Carton

Alle verwendeten CPAN-Module sind in der Datei `cpanfile` (bzw.
`cpanfile.snapshot`) aufgelistet und lassen sich mit `carton install` (bzw.
`carton install --deployment`) ins Verzeichnis `local/` installieren.

## Unit-Tests

    make tests


