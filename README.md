# DokuWiki Docker Image

This image is based on the official [PHP Apache image](https://hub.docker.com/_/php) and provides a DokuWiki
installation. It is meant to be used with a reverse proxy that handles SSL termination and authentication. It's probably
not worth it to use this image for a standalone installation (
read [Running DokuWiki on Docker](https://www.patreon.com/posts/42961375) for alternatives).

## Usage

See docker-compose.yml for an example setup.

  * Exposed Port: 8080
  * Volume: /storage
  * Can be run as non-root user. Be sure the storage volume is writable by the given uid.

On first run, use DokuWiki's installer to configure the wiki as usual.

## Features

  * xsendfile configured and enabled
  * imagemagick installed and enabled
  * nice URLs via rewriting configured and enabled

## PHP Configuration & Environment

The container runs the standard production php.ini. Some options can be set via environment variables:

* `PHP_UPLOADLIMIT` - File upload size limit. Default `128M`
* `PHP_MEMORYLIMIT` - Process Memory Limit. Default `256M`
* `PHP_TIMEZONE` - The timezone. Default `UTC`

Custom PHP configuration values can be set in a `php.ini` file in the storage volume.

## How this image handles user data

Besides the obvious page and media data, extensions and configuration need to be persisted over container replacements.
However it needs to be differentiated between user installed extensions and configuration and bundled extensions and
configuration.

This image uses a single storage volume for all user data.

Bundled Plugins and Templates are moved to separate directories in the container and symlinked to the storage volume.
The storage volume is then symlinked to the proper tpl and plugins location. This means that the storage volume will
never contain stale bundled extensions.

Similarly, the core configuration is moved to a separate directory but the preload mechanism is used to load them as
default. The storage volume will only contain local configuration this way.

Required symlinks are rechecked on every container restart.

This setup ensures that all adjustments you may make via the Admin interface will be stored correctly in the storage
volume while all bundled data is kept in the container and is correctly updated/replaced when the container is updated.
