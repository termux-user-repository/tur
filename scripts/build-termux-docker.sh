#!/bin/sh
set -e -u

: ${TERMUX_BUILDER_IMAGE_NAME:=termux/termux-docker:$ARCH}
: ${CONTAINER_NAME:=termux-$ARCH}

CONTAINER_HOME_DIR=/data/data/com.termux/files/home
UNAME=$(uname)
if [ "$UNAME" = Darwin ]; then
	# Workaround for mac readlink not supporting -f.
	REPOROOT=$PWD
	SEC_OPT=""
else
	REPOROOT="$(dirname $(readlink -f $0))/../"
	SEC_OPT=" --security-opt seccomp=$REPOROOT/scripts/profile.json"
fi

# Check whether attached to tty and adjust docker flags accordingly.
if [ -t 1 ]; then
	DOCKER_TTY=" --tty"
else
	DOCKER_TTY=""
fi

if [ -n "${TERMUX_DOCKER_USE_SUDO-}" ]; then
	SUDO="sudo"
else
	SUDO=""
fi

echo "Running container '$CONTAINER_NAME' from image '$TERMUX_BUILDER_IMAGE_NAME'..."

$SUDO docker start $CONTAINER_NAME >/dev/null 2>&1 || {
	echo "Creating new container..."
	# sudo chmod -R 777 $REPOROOT
	$SUDO docker run \
		--detach \
		--name $CONTAINER_NAME \
		--network=host \
		--volume $REPOROOT:$CONTAINER_HOME_DIR/termux-packages \
		$SEC_OPT \
		--tty \
		-w $CONTAINER_HOME_DIR/termux-packages \
		$TERMUX_BUILDER_IMAGE_NAME
}

if [ "$#" -eq  "0" ]; then
	$SUDO docker exec --interactive $DOCKER_TTY $CONTAINER_NAME bash
else
	$SUDO docker exec --interactive $DOCKER_TTY $CONTAINER_NAME "$@"
fi