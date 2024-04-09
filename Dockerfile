FROM php:8.2-apache

COPY root /


RUN /bin/bash /build-setup.sh

VOLUME /storage
EXPOSE 8080

RUN chmod +x /dokuwiki-entrypoint.sh
ENTRYPOINT ["/dokuwiki-entrypoint.sh"]
