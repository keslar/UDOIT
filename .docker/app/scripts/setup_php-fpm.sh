#!/bin/sh

TYPE=$1
HOST=$2
PORT=$3
USER=$4
PASSWORD=$5
SCHEMA=$6
DIRECTORY=$7

sed -i "s/\$db_type .*/\$db_type = '${TYPE}';/g" "${DIRECTORY}/html/config/localConfig.php"
sed -i "s/\$db_host .*/\$db_host = '${HOST}';/g" "${DIRECTORY}/html/config/localConfig.php"
sed -i "s/\$db_port .*/\$db_port = '${PORT}';/g" "${DIRECTORY}/html/config/localConfig.php"
sed -i "s/\$db_user .*/\$db_user = '${USER}';/g" "${DIRECTORY}/html/config/localConfig.php"
sed -i "s/\$db_password .*/\$db_password = '${PASSWORD}';/g" "${DIRECTORY}/html/config/localConfig.php"
sed -i "s/\$db_name .*/\$db_name = '${SCHEMA}';/g" "${DIRECTORY}/html/config/localConfig.php"

cd ${DIRECTORY}/html
composer install --no-dev
composer db-setup
