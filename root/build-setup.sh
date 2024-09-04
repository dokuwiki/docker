#!/bin/bash
set -x
set -e

# This script is run during the container build process only.
#
# It installs DokuWiki and prepares the storage volume setup.

# PHP ini setup
mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
ln -s /storage/php.ini "$PHP_INI_DIR/conf.d/custom.ini" # make it easy to override php.ini

# Apache setup
a2enconf dokuwiki
a2disconf security
a2enmod rewrite
a2enmod xsendfile

# Download DokuWiki from the official website or from GitHub
curl --fail -L "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${DOKUWIKI_VERSION}.tgz" -o dokuwiki.tgz || \
curl --fail -L "https://github.com/dokuwiki/dokuwiki/archive/refs/heads/master.tar.gz" -o dokuwiki.tgz

# Extract DokuWiki to the web root
tar xzf dokuwiki.tgz --strip-components 1 -C /var/www/html && rm dokuwiki.tgz

# Create volume mount point
mkdir /storage

# Move writable directories and create symlinks to the storage volume
mv /var/www/html/conf /var/www/html/conf.core
ln -s /storage/conf /var/www/html/conf
mv /var/www/html/data /var/www/html/data.core
ln -s /storage/data /var/www/html/data
mv /var/www/html/lib/plugins /var/www/html/lib/plugins.core
ln -s /storage/lib/plugins /var/www/html/lib/plugins
mv /var/www/html/lib/tpl /var/www/html/lib/tpl.core
ln -s /storage/lib/tpl /var/www/html/lib/tpl
mv /var/www/html/lib/images /var/www/html/lib/images.core
ln -s /storage/lib/images /var/www/html/lib/images

# delete all build files
rm -- /build-*
