#!/bin/bash
# "Wesley Silva <wesley.silva@concretesolutions.com.br>"
# Script to manage the containers execution


## Run always from the same directory
if [ -d ".git" ]
then
    echo "$(date) - Starting..." 
else
    echo "You must run this script from the project root directory."
    exit 1
fi


## Command line options
## pass --ephemeral to ignore the local storage
echo "$@" | grep "\-\-ephemeral" && export EPHEMERAL="true"
echo "$@" | grep "\-\-interactive" && export INTERACTIVE="true"


## Define the container name to be used on all places along this script.
# If it is not na oficial image, set the builder too. Do not forget to add
# a slash at the end, like in "BUILDER=wesleyit/myimage".
# The nickname will be used when there are more than one container
# of the same image.
export BUILDER=''
export CONTAINER='node'
export VERSION='5.5.0'
export NICKNAME='beers-api'
export LINK1="--link mongo-beers-api:mongo-beers-api"

## Set the ports used by the service.
## HOST_PORT is used to access the service in localhost.
HOST_PORT1=3000
## CONTAINER_PORT is the port used by the service inside the container.
CONTAINER_PORT1=3000
## This is the string to configure ports on containers.
PORT1="-p $HOST_PORT1:$CONTAINER_PORT1"

## Manage persistence
##STORE_DIR is a localhost directory to bind to
# the remote host. 
STORE_DIR="$(pwd)/app"
## CONTAINER_DATA_DIR is the directory inside the container which will be
# mounted on localhost
CONTAINER_DATA_DIR='/app'
## If the --ephemeral option is set, then don't persist data.
# Otherwise, we need to guarantee the directory exists and is writable.
if [ "$EPHEMERAL" ]
then
    export PERSISTENCE=""
else
    mkdir -p "$STORE_DIR"
    sudo chmod 4775 "$STORE_DIR"
    export PERSISTENCE="-v $STORE_DIR:$CONTAINER_DATA_DIR"
fi


## Verify if the container exists
function is_created() {
    docker ps -a | grep -q "$1"
    return "$?"
}


## Verify if there is an instance of this container executing at this moment
function is_running() {
    docker ps | grep -q "$1"
    return "$?"
}


## If the option --interactive is set, run in the terminal, otherwise
# run as a daemon.
if [ "$INTERACTIVE" ]
then
    echo "Interactive terminal selected."
    export RUN_MODE='-ti'
else
    echo "Daemon mode selected."
    export RUN_MODE='-d'
fi


## Use the following structure to set the environment
# variables. Do not forget to update the start function.
#ENV1=
#ENV2=
#ENV3=


function start() {
    echo -n "Starting container $CONTAINER..."
    docker run $RUN_MODE \
	   --name $NICKNAME \
 	   $PORT1 \
	   $PERSISTENCE \
	   $LINK1 \
	   "$BUILDER""$CONTAINER":"$VERSION" bash -c "cd /app && npm install && npm install -g pm2 && npm install --dev && pm2 start server.js --no-daemon"
}


function stop() {
    if is_created $NICKNAME
    then
	if is_running $NICKNAME
	then
            echo -n "Killing container "
            docker kill $NICKNAME
	fi
	echo -n "Deleting container "
	docker rm $NICKNAME
	sleep 5
    fi
}


function usage() {
cat <<EOF

Usage: $0 [ start | stop | help ]
$0 start [--ephemeral ] [--interactive]: Start the container.
$0 stop: Kill the container
$0 help: Show this message.

EOF
}


case $1 in
    start) stop && start ;;
    stop) stop ;;
    *) usage ;;
esac