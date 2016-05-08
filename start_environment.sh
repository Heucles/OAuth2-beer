#!/bin/bash

## This script must be located at the project root folder.
cd "$(dirname $0)"
WORKDIR="$(pwd)"

# All containers must have a startup script on init_scripts folder.
# The scripts must end with .sh and will be executed in order.
# Example: 01-start_postgresql.sh will run before 05-start_migrations.sh.
for container in ./init-scripts/*.sh
do
    echo -n "Importing the startup file ${container}...  "

    ## This will import all script files executing them.
    ## The STDOUT and STDERR will be redirected to a log file.
    if ${container} start 2>&1 > ./startup.log
    then
	echo '[  OK  ]'
    else
	echo '[ Fail ]'
    fi
done
