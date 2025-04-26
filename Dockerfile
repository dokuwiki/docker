FROM php:8.4-cli AS builder

ENV DOKUWIKI_VERSION=stable
ENV DOKUWIKI_SHA256=7ac919bc298c049af15764f3563ec3012cd158945ef2a22348684df701a19ba3
ENV IMAGICK_VERSION=3.8.0
ENV LIBLDAP=2.5-0

# hadolint ignore=DL3008
RUN apt-get update -qq \
	&& apt-get install -qq --no-install-recommends \
		libfreetype6-dev \
		libjpeg-dev \
		libmagickwand-dev \
		libpng-dev \
		libzip-dev \
        libicu-dev \
        libldap2-dev \
        zlib1g-dev \
        libsqlite3-dev \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install \
		gd \
        bz2 \
		bcmath \
		exif \
		mysqli \
		opcache \
		zip \
        pdo_sqlite \
        intl \
        ldap \
    && pecl install imagick-$IMAGICK_VERSION \
    && docker-php-ext-enable imagick

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -o dokuwiki.tar.gz -fSL "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${DOKUWIKI_VERSION}.tgz" \
    && echo "$DOKUWIKI_SHA256 *dokuwiki.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/dokuwiki \
    && tar -xzf dokuwiki.tar.gz --strip-components 1 -C /usr/src/dokuwiki


FROM php:8.4-apache AS final

# hadolint ignore=DL3008
RUN apt-get update -qq \
    && apt-get install -qq --no-install-recommends \
		less \
		libfreetype6 \
		libjpeg62-turbo \
		libmagickwand-6.q16-6 \
		libpng16-16 \
		libzip4 \
        libicu72 \
        libldap-2.5-0 \
        libapache2-mod-xsendfile \
        imagemagick \
        sqlite3 \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy installed PHP extensions from builder
COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d
COPY --from=builder /usr/local/include/php /usr/local/include/php
COPY --from=builder --chown=www-data:www-data /usr/src/dokuwiki/ /var/www/html


# FROM php:8.3-apache AS dokuwiki-base

# additional extensions can be passed as build-arg
# ARG PHP_EXTENSIONS=""

# COPY root/build-deps.sh /
# RUN /bin/bash /build-deps.sh


# FROM dokuwiki-base

# ARG DOKUWIKI_VERSION=stable

ENV PHP_UPLOADLIMIT=128M
ENV PHP_MEMORYLIMIT=256M
ENV PHP_TIMEZONE=America/Chicago

# COPY root /
# RUN /bin/bash /build-setup.sh

COPY --chown=root:root root/etc/apache2 /etc/apache2/
COPY --chown=root:root root/usr/local/etc/php /usr/local/etc/php/
COPY --chown=root:root root/dokuwiki-entrypoint.sh /usr/local/bin/
COPY --chown=root:root root/dokuwiki-storagesetup.sh /usr/local/bin/
COPY --chown=www-data:www-data root/var/www/html /var/www/html/

# Enable and disable Apache configurations and modules
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
 && chmod +x /usr/local/bin/dokuwiki-entrypoint.sh \
 && a2enconf dokuwiki \
 && a2disconf security \
 && a2enmod rewrite \
 && a2enmod xsendfile

# Create volume mount point
RUN mkdir /storage \
    && mv /var/www/html/conf /var/www/html/conf.core \
    && ln -s /storage/conf /var/www/html/conf \
    && mv /var/www/html/data /var/www/html/data.core \
    && ln -s /storage/data /var/www/html/data \
    && mv /var/www/html/lib/plugins /var/www/html/lib/plugins.core \
    && ln -s /storage/lib/plugins /var/www/html/lib/plugins \
    && mv /var/www/html/lib/tpl /var/www/html/lib/tpl.core \
    && ln -s /storage/lib/tpl /var/www/html/lib/tpl

VOLUME /storage
EXPOSE 8080

# Moved to docker-compose.yml
# HEALTHCHECK --timeout=5s \
#     CMD curl --silent --fail-with-body http://localhost:8080/health.php || exit 1

# RUN chmod +x /dokuwiki-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/dokuwiki-entrypoint.sh"]
