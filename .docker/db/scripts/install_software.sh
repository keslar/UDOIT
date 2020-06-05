#!/bin/sh

PACKAGES=""
if [ -n "$PACKAGES" ]; then
   if [ -n "$DISTRO" ]  && [ "$DISTRO" = "Debian" ]; then
      apt-get update -yqq
      apt-get install ${PACKAGES} -yqq
   elif [ -n "$DISTRO" ]  && [ "$DISTRO" = "Alpine" ]; then
      apk update
      apk add --no-cache ${PACKAGES}
   else
      ls -al
   fi
fi
