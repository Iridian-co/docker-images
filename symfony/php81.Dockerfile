FROM composer:2 as composer

FROM php:8.1-fpm-alpine as base

ARG USER_UID=82
ARG USER_GID=82

ARG COMPOSER_ALLOW_SUPERUSER=1

RUN apk add --update nodejs npm
RUN node --version
RUN npm i -g yarn
RUN yarn --version

# Recreate www-data user with user id matching the host
RUN deluser --remove-home www-data && \
    addgroup -S -g ${USER_GID} www-data && \
    adduser -u ${USER_UID} -D -S -G www-data www-data

# Necessary tools
RUN apk add --update --no-cache ${PHPIZE_DEPS} git curl

# ZIP module
RUN apk add --no-cache libzip-dev && docker-php-ext-configure zip && docker-php-ext-install zip
RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-enable pdo_mysql mysqli
RUN apk add icu-dev
RUN docker-php-ext-configure intl && docker-php-ext-install intl

# Imagick module
RUN apk add --no-cache libgomp imagemagick imagemagick-dev && \
	pecl install -o -f imagick && \
	docker-php-ext-enable imagick

# Redis
RUN pecl install redis && docker-php-ext-enable redis

# Symfony CLI tool
RUN apk add --no-cache bash && \
	curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | bash && \
	apk add symfony-cli && \
	apk del bash

# XDebug from PECL
#RUN pecl install xdebug-3.1.5

# Necessary build deps not longer needed
RUN apk del --no-cache ${PHPIZE_DEPS} \
    && docker-php-source delete

# Composer
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# XDebug wrapper
#COPY ./artifacts/xdebug /usr/local/bin/xdebug
#RUN chmod +x /usr/local/bin/xdebug

# Clean up image
RUN rm -rf /tmp/* /var/cache

RUN apk add --no-cache sqlite


