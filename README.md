# NAME

libsites - GBV-Standortverzeichnis

# SYNOPSIS

The application is automatically started as service, listening on port 6013

    sudo service libsites {status|start|stop|restart}

# DESCRIPTION

libsites implements an RDF-based web registry of library locations.

# INSTALLATION

Create user `libsites` and directories:

    sudo adduser --home /srv/libsites --disabled-password libsites
    sudo mkdir /etc/libsites /var/log/libsites
    sudo chown libsites:libsites /etc/libsites /var/log/libsites

Install dependencies:

    sudo apt-get install git libcatmandu-perl librdf-trine-perl libgit-repository-perl liblog-contextual-perl starman 

Clone this repository as user `libsites` in `/srv/libsites`

    sudo -iu libsites

    git clone --bare https://github.com/gbv/libsites.git .git
    git config --unset core.bare
    git checkout .

    git clone https://github.com/gbv/libsites-config.git /etc/libsites
    ln -s /etc/libsites libsites-config

Locally install Perl libraries

    make -B local

The actual content is retrieved from the German ISIL directory (hosted by ZDB)
and the git repository <https://github.com/gbv/libsites-config> among other sources.

Initally update data of libraries (will take a while):

    perl -Ilib -Ilocal/lib/perl5 bin/update all

Add a cronjob (`crontab -e`) to daily update the data, e.g.

    10 03 * * * perl -Ilib -Ilocal/lib/perl5 bin/update all

Switch back to root and enable the service by copying `libsites.init` to `/etc/init.d/libsites` and update runlevel directories with `update-rc.d libsites defaults`. then start the service

    sudo cp /srv/libsites/libsites.init /etc/init.d/libsites
    sudo update-rc.d libsites defaults
    sudo service libsites start

After installation the service is available at localhost on port 6013. Better
put the service behind a reverse proxy to enable SSL and nice URLs!

# ADMINISTRATION

## Updates of content

A full update is run daily and logged to `/var/log/libsites/update.log`. At URL
path `/update` there is also a GitHub Webhook to trigger update from configuration
repository `libsites-config`. The update script can be run manually as following:

    cd /srv/libsites && sudo -u libsites perl -Ilib -Ilocal/lib/perl5 bin/update all

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
