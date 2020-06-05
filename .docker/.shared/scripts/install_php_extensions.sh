#!/bin/sh

apt-get update -yqq

apt-get install -yqq \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
	      libpng-dev \
	      libpq-dev 

docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ 

docker-php-ext-install \
        gd \
	      pdo \
	      pdo_mysql \
	      pdo_pgsql