#!/bin/sh
# run this script as the USER postgres from Dockerfile

DBNAME=$1
DBUSER=$2
DBPASS=$3

# Create the database 
createdb $DBNAME

# Create the application user
echo $DBPASS | createuser $DBUSER --pwprompt --encrypted

# Grant the user all privileges to the database
echo 'grant all privileges on database "UDOIT" to udoit;\q' | psql