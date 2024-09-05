# Basic environment for managing projects and running hello world
# hadolint global ignore=DL3059
FROM php:8.3-apache

RUN apt-get update -y && apt-get upgrade -y

# Install requirements
RUN apt-get install -y \
    git \
    openssh-client

# xml extensions
RUN apt-get install -y --no-install-recommends libxml2-dev \
    && docker-php-ext-install simplexml xml

# zip extension
RUN apt-get install -y --no-install-recommends libzip-dev zip \
    && docker-php-ext-install zip

# mbstring extension
RUN apt-get install -y libonig-dev \
    && docker-php-ext-install mbstring

# GD extension
RUN apt-get install -y --no-install-recommends libfreetype6-dev  libjpeg62-turbo-dev libpng-dev \
        && docker-php-ext-install gd

RUN docker-php-ext-install bcmath

# Other php extensions
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    soap \
    intl \
    sysvsem \
    calendar \
    sockets

RUN docker-php-ext-enable \
    gd \
    bcmath \
    mbstring \
    pdo \
    pdo_mysql \
    soap \
    intl \
    sysvsem \
    calendar \
    sockets \
    zip \
    xml \
    simplexml

ENV WORKDIR="/var/www/html"
WORKDIR "${WORKDIR}"

# Configure APACHE
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

# install composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Get NodeJS & NPM from node image
RUN apt-get install -y libstdc++6
COPY --from=node:16.17.0 /usr/local/bin /usr/local/bin
COPY --from=node:16.17.0 /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN npm i npm@^8.15.0 -g --no-audit --progress=false