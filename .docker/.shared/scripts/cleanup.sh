#!/bin/sh

if [ -n "$DISTRO" ]  && [ "$DISTRO" = "Debian" ]; then
   apt-get clean -yqq
   rm -rf /var/lib/apt/lists/* 
elif [ -n "$DISTRO" ]  && [ "$DISTRO" = "Alpine" ]; then
   apk update
   apk add --no-cache ${PACKAGES}
else
   ls -al
fi

if [ -e /usr/bin/apt ]; then
    apt-get clean
    
else
    apk del .build-deps -q
    apk cache clean -q
fi

rm -rf /tmp/* \
       /var/tmp/* \
       /var/log/lastlog \
       /var/log/faillog

