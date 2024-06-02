#!/bin/bash
set -x
set -e

# This script is run during the base container build process only.
#
# It installs the OS and webserver dependencies and builds the required PHP extensions.
# The resulting container is DokuWiki independent and can be reused for different version containers.

# install dependencies
apt-get update
apt-get install -y \
        imagemagick \
        libapache2-mod-xsendfile \
        libbz2-dev \
        libfreetype-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libsqlite3-dev
apt-get autoclean

# build and enable PHP extensions
docker-php-ext-configure gd --with-freetype --with-jpeg
docker-php-ext-install -j"$(nproc)" gd
docker-php-ext-install -j"$(nproc)" bz2
docker-php-ext-install -j"$(nproc)" opcache
docker-php-ext-install -j"$(nproc)" pdo_sqlite
docker-php-ext-install -j"$(nproc)" intl

# delete self
rm -- "$0"
