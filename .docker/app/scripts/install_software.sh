#!/bin/sh

if [ -n "$DISTRO" ]  && [ "$DISTRO" = "Debian" ]; then
  apt-get update -yqq
  apt-get install zip unzip autoconf git libfreetype6-dev libjpeg62-turbo-dev libpng-dev libpq-dev -yqq
elif [ -n "$DISTRO" ]  && [ "$DISTRO" = "Alpine" ]; then
  apk upgrade --update
  apk add --no-cache autoconf build-base freetype-dev git libjpeg-turbo-dev libpng-dev postgresql-dev 
else 
  ls -al
fi

docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ 
docker-php-ext-install gd pdo_pgsql

# Install composer
cd /tmp
curl -sS https://getcomposer.org/installer -o composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer