# Basic environment for managing projects and running hello world
# hadolint global ignore=DL3059
FROM php:8.3-apache

RUN apt-get update -y && apt-get upgrade -y

# install libs
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libzip-dev
RUN apt-get install -y zip

# GD extension
RUN apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        && docker-php-ext-configure gd
        && docker-php-ext-install gd

# zip extension
RUN docker-php-ext-configure zip && docker-php-ext-install zip

# bcmath extension
RUN docker-php-ext-configure bcmath --enable-bcmath && docker-php-ext-install bcmath

RUN docker-php-ext-install sockets && docker-php-ext-configure sockets && docker-php-ext-enable sockets

# install php extensions
RUN docker-php-ext-install \
    mbstring \
    pdo \
    pdo_mysql \
    soap \
    intl \
    sysvsem \
    calendar

ENV WORKDIR="/var/www/html"
WORKDIR "${WORKDIR}"

# Apache
HEALTHCHECK --interval=30s CMD curl --fail http://localhost/  # TODO --start-interval=15s --interval=5m
ENV APACHE_DOCUMENT_ROOT="${WORKDIR}/public"
RUN a2enmod rewrite
# https://github.com/docker-library/php/issues/1082
RUN sed -ri -e "s!${WORKDIR}!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf
# https://www.tenable.com/audits/items/CIS_Apache_HTTP_Server_2.4_Benchmark_v2.0.0_Level_1.audit:3e40bb6b17d51e608448449f08a3b496
RUN usermod --append --groups root www-data \
        && usermod --append --groups www-data root \
        && chmod 0777 -R /tmp

# PHP
RUN echo "memory_limit = 512M" > "${PHP_INI_DIR}/conf.d/memory_limit.ini"

# --> install composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# --> get node & npm from node image
COPY --from=node:lts-alpine /usr/local/bin /usr/local/bin
COPY --from=node:lts-alpine /usr/local/lib/node_modules /usr/local/lib/node_modules
