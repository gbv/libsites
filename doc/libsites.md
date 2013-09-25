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

## Definition von Standorten

Die grundlegenden Organisationseinheit im Standortverzeichnis bilden
Einrichtungen mit ISIL. Diesen Einrichtungen können zusätzlich Standorte
untergeordnet werden. Was genau einen Standort ausmacht, liegt im Ermessen der
jeweiligen Einrichtung. Im einfachsten Fall bildet die Einrichtung selber den
einzigen Standort während im umfangreichsten Fall jeder Raum als eigener
Standort definiert wird. Als Faustregel gilt, dass ein Standort über eine
gewisse Eigenständigkeit verfügen sollte (eigene Adresse, Öffnungszeiten,
Zugangsbedingungen, Homepage o.Ä.). 

**Beispiel**: Die Universitätsbibliothek Hildesheim (ISIL DE-Hil2) verfügt über
die drei Standorte "AZP-Bibliothek", "AMI-Medienzentrum" und "Handapparat". Je
nach Anwendung kommt noch die UB Hildesheim selber als Standard-Standort hinzu.

Es lassen sich zwei Arten von Standorten unterscheiden:

1. **Unselbständige Standorte** die genau einer Einrichtung untergeordnet sind. 
   Diese Standorte werden durch ein frei wählbares alphanumerisches Kürzel
   (Kleinbuchstaben) im Zusammenhang mit dem ISIL der übergeordneten Einrichtung
   identifiziert, wobei dem Kürzel das Zeichen '`@`' vorangestellt wird.
   Beispielsweise hat die AZP-Bibliothek  das Kürzel `DE-Hil2@azp`

2. **Selbstständige Standorte** die ihrerseits Einrichtungen mit eigener ISIL sind.
   Beispielsweise ist die Bibliothek im Kurt-Schwitters-Forum (ISIL DE-960-3)
   ein Standort der Bibliothek der Hochschule Hannover (ISIL DE-960). 
   Selbständige Standorte können im Gegensatz zu unselbständigen Standorten 
   bei Bedarf auch untergeordnete Standorte *mehrerer* Einrichtungen sein.

Weitere Details zur Definition von Standorten und ihren Eigenschaften siehe
unter [Konfiguration]. Zusätzlich zu Standorten kann es weitere Informationen
zur Lokalisierung geben, die nicht in die VZG-Standortverwaltung integriert
sind. Beispielsweise definiert DAIA zusätzlich Plätze ("storage") unterhalb von
Standorten. Dies hat den Vorteil, dass sich Standorte weiter differenzieren
lassen, ohne ihre Anzahl unnötig aufzublähen. Typische Beispiele sind Standorte
wie "Magazin" oder "Handapparat", die lediglich innerhalb der
Standortverwaltung eine Einheit bilden.

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

# Konfiguration

[Konfiguration]: #konfiguration

Die in der VZG-Standortverwaltung zusammengeführten Datenquellen und
zusätzliche Standortinformationen werden in einem eigenen git-Repository
verwaltet, das auf GitHub unter <https://github.com/gbv/libsites-config>
einsehbar ist. Bei Änderungen an diesem Repository wird die [Installation]
unter <http://uri.gbv.de/organization/> per WebHook benachrichtigt, so
dass Aktualisierungen dort innerhalb einiger Minuten erscheinen.

Das Konfigurations-Repository enthält im Verzeichnis `isil` für jede zu
konfigurierende Einrichtung ein Unterverzeichnis mit dem ISIL der jeweiligen
Einrichtung als Namen. In diesem Verzeichnis kann eine Datei `sites.txt` mit
den Standortdefinitionen angelegt werden. Beispielsweise liegen die
Standortinformationen für die UB Hildesheim unter `isil/DE-Hil2/sites.txt`.

## Aufbau einer Konfigurationsdatei

Die Datei `sites.txt` ist eine reine Textdatei in UTF-8-Kodierung (d.h. sie
sollte *nicht* mit Excel, Word o.Ä. Office-Programmen bearbeitet werden!). Die
Datei wird zur Interpretation zeilenweise gelesen und enthält eine Liste von
Standorten, die folgendermaßen aufgebaut ist:

1. Jeder Standort wird durch eine Zeile eingeleitet in der als Identifer der
   ISIL bzw. das Kürzel des Standorts steht. Der ISIL kann die Zeichenkette 
   "`ISIL `" vorangestellt werden. Für die übergeordnete Einrichtung kann auch
   das Kürzel '`@`' verwendet werden.

2. Die folgende Zeile enthält den Namen des Standortes.

3. Alle anschließenden Zeile bis zum nächsten Standort-Identifier oder Dateiende
   werden durch Muster überprüft, ob sie eine Email-Adresse, Homepage-URL, 
   Koordinate, Telefonnummer oder Öffnungszeiten enthalten. Öffnungszeiten
   können im Gegensatz zu den anderen Angaben auch mehrfach vorkommen.

4. Solange kein Muster passt werden alle Zeilen bis zur ersten Leerzeile als 
   Adresse interpretiert.

4. Alle übrigen Zeilen werden als Kommentar oder Kurzbeschreibung des Standortes
   interpretiert.

Im Quellcode der Standortverwaltung befindet sich das Perl-Modul
`GBV::App::Libsites::Parser` zum Einlesen des hier beschriebenen Textformates.
Der Einfachkeit halber bietet es sich an, zum Anlegen neuer Einrichtungen von
vorhandenen Konfigurationsdateien als Beispiel auszugehen. Die formale Syntax 
richtet sich nach folgenden Regeln:

    Identifier     ::= ISIL | Kürzel
    ISIL           ::= 'ISIL '? [A-Z]{1,4} '-' [A-Za-z0-9/:-]+
    Kürzel         ::= '@' [a-z0-9]*
    EMail          ::= [^@ ]+ '@' [^@ ]+
    Homepage       ::= 'http' 's'? '://' Char+
    Koordinate     ::= [0-9]+ '.' [0-9] Whitespace* [,/;] Whitespace* 
                       [0-9]+ '.' [0-9]
    Telefon        ::= ( '+' | '(+' )? [0-9()/ -]+
    Öffnungszeiten ::= ( ( [0-9][0-9] ':' [0-9][0-9] ) | 'Uhr' ) &&
                       ( 'Mo' | 'Di' | 'Mi' | 'Do' | 'Fr' | 'Sa' | 'So' )


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


