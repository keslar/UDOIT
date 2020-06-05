#!/bin/sh
PASSWORD=$1
USER=$2
SCHEMA=$3
DATADIR=$4

# Create the data directory
mkdir -p ${DATADIR}/data;
mkdir -p ${DATADIR}/data/pgdata

# set owner and permissions
chown -Rvf ${USER} "${DATADIR}/data"
chmod -Rvf 0750 "${DATADIR}/data"