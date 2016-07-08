# NAME

libsites - GBV-Standortverzeichnis

# SYNOPSIS

The application is automatically started as service, listening on port 6013

    sudo service libsites {status|start|stop|restart}

# DESCRIPTION

libsites implements an RDF-based web registry of library locations.

# INSTALLATION

The software is released as Debian package for Ubuntu 14.04 LTS. Other Debian
based distributions *might* work too. Releases can be found at
<https://github.com/gbv/libsites/releases>

To install required dependencies either use a package manager such as `gdebi`,
manually install dependencies (inspectable via `dpkg -I libsites_*.deb`):

    sudo dpkg -i ...                         # install dependencies
    sudo dpkg -i libsites_X.Y.Z_amd64.deb    # change X.Y.Z

After installation the service is available at localhost on port 6013. Better
put the service behind a reverse proxy to enable SSL and nice URLs!

The installation does not trigger running the daily cronjob to update from
libsites-config and ZDB, so you may need to manually run it after installation:

    sudo -u libsites /etc/cron.daily/libsites

# ADMINISTRATION

## Configuration

Config file `/etc/default/libsites` only contains basic server configuration
in form of simple key-values pairs:

* `PORT`    - port number (required, 6013 by default)
* `WORKERS` - number of parallel connections (required, 5 by default).

The actual content is retrieved from the German ISIL directory (hosted by ZDB)
and the git repository <https://github.com/gbv/libsites-config>.

## Updates of content

Ein Update läuft täglich sowie (ohne ZDB-Update) bei Benachrichtigung per
GitHub Webhook an den URL-Pfad `/update`. Der Verlauf des Update-Skripts wird
in `/var/log/libsites/update.log` festgehalten. Zur Not kann das Update auch
manuell angestoßen werden:

    sudo -u libsites /etc/cron.daily/libsites

## Logging

Log files are written in `/var/log/libsites/` and kept for 30 day by default:

* `access.log` - HTTP request and responses in Apache Log Format
* `server.log` - Web server messages (when server was started and stopped)
* `update.log` - Update script output

# SEE ALSO

The source code of libsites is managed in a public git repository at
<https://github.com/gbv/libsites>. Please report bugs and feature request at
<https://github.com/gbv/libsites/issues>!

The Changelog is located in file `debian/changelog`.

Development guidelines are given in file `CONTRIBUTING.md`.

