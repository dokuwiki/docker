#!/bin/bash
set -x
set -e

# copy core data directories to the volume
# this will update syntax.txt etc. on image update
mkdir -p /storage/data
cp -r /var/www/html/data.core/. /storage/data  # includes hidden files

# ensure the conf directory exists, defaults are set via config_cascade
mkdir -p /storage/conf

# installer does not use config_cascade so we have to symlink the license file
[ -L /storage/conf/license.php ] && rm /storage/conf/license.php
[ -e /storage/conf/license.php ] && rm /storage/conf/license.php
ln -s /var/www/html/conf.core/license.php /storage/conf/license.php

# core extensions are symlinked to the volume
for ext in plugins tpl; do
  mkdir -p /storage/lib/$ext
  for dir in /var/www/html/lib/$ext.core/*; do
    base=$(basename $dir)
    [ -d "/storage/lib/$ext/$base" ] && rm -r /storage/lib/$ext/$base
    [ -f "/storage/lib/$ext/$base" ] && rm /storage/lib/$ext/$base
    [ -L "/storage/lib/$ext/$base" ] && rm /storage/lib/$ext/$base
    ln -s $dir /storage/lib/$ext/$base
  done
done

# smileys are symlinked to volume so they work per dokuwiki docs
for ext in smileys; do
  mkdir -p /storage/lib/images/$ext
  for dir in /var/www/html/lib/images/$ext.core/*; do
    base=$(basename $dir)
    [ -d "/storage/lib/images/$ext/$base" ] && rm -r /storage/lib/images/$ext/$base
    [ -f "/storage/lib/images/$ext/$base" ] && rm /storage/lib/images/$ext/$base
    [ -L "/storage/lib/images/$ext/$base" ] && rm /storage/lib/images/$ext/$base
    ln -s $dir /storage/lib/images/$ext/$base
  done
done


