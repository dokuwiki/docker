# DokuWiki Docker Image

This image is based on the official [PHP Apache image](https://hub.docker.com/_/php) and provides a DokuWiki
installation. It is meant to be used with a reverse proxy that handles SSL termination and authentication. It's probably
not worth it to use this image for a standalone installation 
(read [Running DokuWiki on Docker](https://www.patreon.com/posts/42961375) for alternatives). Running Docker without a
proper understanding of Linux, networking and Docker itself is not recommended. If you are a novice, you should probably
use a shared hosting provider instead.

If you use this image, **please leave a star at [Docker Hub](https://hub.docker.com/r/dokuwiki/dokuwiki)⭐**- it helps
to improve the visibility in the registry.

## Quick Start:

    docker run -p 8080:8080 --user 1000:1000 -v /path/to/storage:/storage dokuwiki/dokuwiki:stable

* Exposed Port: `8080`
* Volume: `/storage`
* Can be run as non-root user. Be sure the storage volume is writable by the given uid.
* Available tags: `stable`, `oldstable`, `master` and versions like `2020-07-29a`. `latest` is an alias for `stable`.

An example [docker-compose file](docker-compose.yml) is included in the repository.

On first run, use DokuWiki's [installer](https://www.dokuwiki.org/installer) to configure the wiki as usual.

## Features

* xsendfile configured and enabled
* imagemagick installed and enabled
* nice URLs via rewriting configured and enabled
* farming support via the [farmer plugin](https://www.dokuwiki.org/plugin:farmer)
* docker health check running basic DokuWiki checks (every 30 seconds, 3 retries)

Note: This image does **not** include a mail server. You need to configure DokuWiki to use an external mail server, this
is most easily achieved using the [SMTP plugin](https://www.dokuwiki.org/plugin:smtp).

## PHP Configuration & Environment

The container runs the standard production php.ini. Some options can be set via environment variables:

* `PHP_UPLOADLIMIT` - File upload size limit. Default `128M`
* `PHP_MEMORYLIMIT` - Process Memory Limit. Default `256M`
* `PHP_TIMEZONE` - The timezone. Default `UTC`

Custom PHP configuration values can be set in a `php.ini` file in the storage volume.

## Permissions

When the container is started without setting an explicit user id (as the compose file suggests), the image will start as
`root` (uid:`0` gid:`0`) and Apache will drop privileges to `www-data` (uid: `33` gid:`33`). Before this happens, the
entrypoint script will use the `root` privileges to recursively chown everything in `/storage` to `33:33`.

When started with any other user id, the whole container will run under that id. You have to ensure that anything mounted
to `/storage` is writable by that uid.

The entry script will print some info about it's effective uid and gid during container start.

## Farming

This image supports farming via the [farmer plugin](https://www.dokuwiki.org/plugin:farmer). To use it, install the
plugin and configure it as described in the plugin documentation. The initial farm configuration is already done in this
image. The farm directory is `/storage/farm`.

Use a reverse proxy to route animal requests to this container.

## How this image handles user data

Besides the obvious page and media data, extensions and configuration need to be persisted over container replacements.
However, it needs to be differentiated between user installed extensions and configuration and bundled extensions and
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

## Development

To manually build the image:

    docker build --build-arg="DOKUWIKI_VERSION=stable" -t dokuwiki/dokuwiki:stable .

Additional PHP extensions can be added to the image using the `PHP_EXTENSIONS` build argument. The value should be a space separated list of PHP extension names as understood by [docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer). For example:

    docker build --build-arg="PHP_EXTENSIONS=pdo_pgsql pdo_mysql" -t dokuwiki/dokuwiki:stable .

Builds are currently done daily using
the [GitHub Actions workflow](https://github.com/dokuwiki/docker/actions/workflows/docker.yml) and new images are pushed for all upstream changes.
