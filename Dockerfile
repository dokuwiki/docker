FROM php:8.2-apache

ENV PHP_UPLOADLIMIT 128M
ENV PHP_MEMORYLIMIT 256M
ENV PHP_TIMEZONE UTC


COPY root /
RUN /bin/bash /build-setup.sh

VOLUME /storage
EXPOSE 8080

RUN chmod +x /dokuwiki-entrypoint.sh
ENTRYPOINT ["/dokuwiki-entrypoint.sh"]
