# NAME

libsites - GBV-Standortverzeichnis

# SYNOPSIS

The application is automatically started as service, listening on port 6013

    sudo service libsites {status|start|stop|restart}

# DESCRIPTION

libsites implements an RDF-based web registry of library locations.

# INSTALLATION

Create user `libsites`:

    sudo adduser --home /srv/libsites --disabled-password libsites

Install dependencies:

    sudo apt-get install git libcatmandu-perl librdf-trine-perl libgit-repository-perl liblog-contextual-perl starman 

Clone this repository as user `libsites` in `/srv/libsites`

    sudo -iu libsites

    git clone --bare https://github.com/gbv/libsites.git .git
    git config --unset core.bare

Locally install Perl libraries

    make local

*...additional steps...*

After installation the service is available at localhost on port 6013. Better
put the service behind a reverse proxy to enable SSL and nice URLs!

The installation does not trigger running the daily cronjob to update from
libsites-config and ZDB, so you may need to manually run as described below.

# ADMINISTRATION

## Configuration

Config file `/etc/default/libsites` only contains basic server configuration
in form of simple key-values pairs:

* `PORT`    - port number (required, 6013 by default)
* `WORKERS` - number of parallel connections (required, 5 by default).

The actual content is retrieved from the German ISIL directory (hosted by ZDB)
and the git repository <https://github.com/gbv/libsites-config>.

## Updates of content

A full update is run daily and logged to `/var/log/libsites/update.log`. At URL
path `/update` there is also a GitHub Webhook to trigger update from configuration
repository `libsites-config`. The update script can be run manually as following:

    sudo -u libsites /etc/cron.daily/libsites all

Remove the parameter `all` for usage help.

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

