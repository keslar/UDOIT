#!/bin/sh

PACKAGES="autoconf curl git unzip"
if [ -n "$PACKAGES" ]; then
   if [ -n "$DISTRO" ]  && [ "$DISTRO" = "Debian" ]; then
      PACKAGES="${PACKAGES} iputils-ping"
      DEBIAN_FRONTEND=noninteractive
      apt-get update -yqq
      apt-get install libapt-inst apt-utils dialog -yqq
      apt-get install ${PACKAGES} -yqq
   elif [ -n "$DISTRO" ]  && [ "$DISTRO" = "Alpine" ]; then
      PACKAGES="${PACKAGES} iputils"
      apk update
      apk add --no-cache ${PACKAGES}
   else
      ls -al
   fi
fi

