#!/bin/bash
set -x
set -e

# when the container runs as root, apache will drop privileges and run
# as www-data(33), we do the same for the storage setup
if [ "$EUID" -eq 0 ]; then
  # make sure we have access to the storage volume
  chown -R www-data:www-data /storage
  # drop privileges and run setup
  setpriv --reuid=33 --regid=33 --init-groups /dokuwiki-storagesetup.sh
else
  # we are already running as unprivileged user, just run setup
  /dokuwiki-storagesetup.sh
fi

# run parent image's entrypoint
exec docker-php-entrypoint apache2-foreground
