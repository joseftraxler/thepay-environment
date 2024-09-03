# Basic environment for managing projects and running hello world
# hadolint global ignore=DL3059
FROM php:8.3-apache

ENV WORKDIR="/var/www/html"
WORKDIR "${WORKDIR}"

# Composer
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git \
      unzip \
 && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php -r "copy('https://composer.github.io/installer.sig', 'composer-setup.php.sig');" \
 && php -r "if (trim(hash_file('SHA384', 'composer-setup.php')) === trim(file_get_contents('composer-setup.php.sig'))) { echo 'Installer verified' . PHP_EOL; exit(0); } else { echo 'Installer corrupt' . PHP_EOL; unlink('composer-setup.php'); unlink('composer-setup.php.sig'); exit(-1); }" \
 && php composer-setup.php \
 && php -r "unlink('composer-setup.php'); unlink('composer-setup.php.sig');" \
 && mv composer.phar /usr/local/bin/composer \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
;

# Apache
HEALTHCHECK --interval=30s CMD curl --fail http://localhost/  # TODO --start-interval=15s --interval=5m
ENV APACHE_DOCUMENT_ROOT="${WORKDIR}/public"
RUN a2enmod rewrite
# https://github.com/docker-library/php/issues/1082
RUN sed -ri -e "s!${WORKDIR}!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf
# https://www.tenable.com/audits/items/CIS_Apache_HTTP_Server_2.4_Benchmark_v2.0.0_Level_1.audit:3e40bb6b17d51e608448449f08a3b496
RUN usermod --append --groups root www-data \
 && usermod --append --groups www-data root \
 && chmod ug+rwX -R /tmp \
;

# PHP
RUN echo "memory_limit = 512M" > "${PHP_INI_DIR}/conf.d/memory_limit.ini"
