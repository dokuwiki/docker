#!/bin/bash
set -x
set -e

# This script is run during the container build process only.

# Create volume mount point
mkdir /storage

# Apache setup
a2enconf dokuwiki
a2disconf security

# PHP ini setup
mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
ln -s /storage/php.ini "$PHP_INI_DIR/conf.d/custom.ini" # make it easy to override php.ini

# Install DokuWiki
curl -L https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz | tar xz --strip-components 1 -C /var/www/html

# Move writable directories and create symlinks to the storage volume
mv /var/www/html/conf /var/www/html/conf.core
ln -s /storage/conf /var/www/html/conf
mv /var/www/html/data /var/www/html/data.core
ln -s /storage/data /var/www/html/data
mv /var/www/html/lib/plugins /var/www/html/lib/plugins.core
ln -s /storage/lib/plugins /var/www/html/lib/plugins
mv /var/www/html/lib/tpl /var/www/html/lib/tpl.core
ln -s /storage/lib/tpl /var/www/html/lib/tpl

# delete self
rm -- "$0"
