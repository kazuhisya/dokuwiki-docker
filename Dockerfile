# vi: set ft=dockerfile :
FROM alpine:3.6
LABEL maintainer "Kazuhisa Hara <kazuhisya@gmail.com>"

ENV TZ="Asia/Tokyo" \
    PORT="8080" \
    PHP_MEMORY_LIMIT="128M" \
    PHP_MAX_UPLOAD="50M" \
    PHP_MAX_FILE_UPLOAD="20" \
    PHP_MAX_POST="50M" \
    DOKUWIKI_VERSION="dokuwiki-stable"
    #DOKUWIKI_VERSION="dokuwiki-2017-02-19e"

RUN apk --update add \
        apache2 \
        bash \
        curl \
        php7 \
        php7-apache2 \
        php7-apcu \
        php7-ctype \
        php7-curl \
        php7-dom \
        php7-fileinfo \
        php7-gd \
        php7-iconv \
        php7-imagick \
        php7-intl \
        php7-json \
        php7-mbstring \
        php7-opcache \
        php7-openssl\
        php7-session \
        php7-simplexml \
        php7-soap \
        php7-tokenizer \
        php7-xmlreader \
        php7-xmlrpc \
        php7-zip \
        php7-zlib \
        tar && \
        rm -f /var/cache/apk/*

EXPOSE ${PORT}
RUN echo "date.timezone = '${TZ}'\n" > /etc/php7/conf.d/timezone.ini && \
    sed -ri \
        -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
        -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
        -e 's/Listen 80[[:space:]]*$/Listen ${PORT}/g' \
        "/etc/apache2/httpd.conf" && \
    sed -ri \
        -e 's|;*date.timezone =.*|date.timezone = ${TZ}|g' \
        -e 's|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|g' \
        -e 's|;*upload_max_filesize =.*|upload_max_filesize = ${PHP_MAX_UPLOAD}|g' \
        -e 's|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|g' \
        -e 's|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|g' \
        "/etc/php7/php.ini"

RUN curl -OL https://download.dokuwiki.org/src/dokuwiki/${DOKUWIKI_VERSION}.tgz && \
    mv ${DOKUWIKI_VERSION}.tgz dokuwiki.tgz && \
    mkdir -p /run/apache2 && chmod 777 /run/apache2 && \
    chgrp -R 0 /var/www/localhost/htdocs && \
    chmod -R g=u /var/www/localhost/htdocs

COPY src/start.sh /start.sh
COPY src/dokuwiki.conf /etc/apache2/conf.d/dokuwiki.conf

USER 10001

VOLUME ["/var/www/localhost/htdocs"]
CMD ["/start.sh"]
