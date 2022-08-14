#!/bin/sh
set -e -u

TUR_SCRIPTDIR="$(realpath "$(dirname "$0")")"
TERMUX_SCRIPTDIR=$TUR_SCRIPTDIR/termux-packages
CONTAINER_HOME_DIR=/home/builder

UNAME=$(uname)
if [ "$UNAME" = Darwin ]; then
	# Workaround for mac readlink not supporting -f.
	REPOROOT=$PWD
	SEC_OPT=""
else
	REPOROOT="$(dirname $(readlink -f $0))"
	SEC_OPT=" --security-opt seccomp=$TERMUX_SCRIPTDIR/scripts/profile.json"
fi

# Required for Linux with SELinux and btrfs to avoid permission issues, eg: Fedora
# To reset, use "restorecon -Fr ."
# To check, use "ls -Z ."
if [ -n "$(command -v getenforce)" ] && [ "$(getenforce)" = Enforcing ]; then
        VOLUME_termux=$TERMUX_SCRIPTDIR:$CONTAINER_HOME_DIR/termux-packages:z
        VOLUME_termuxrc=$REPOROOT/termuxrc:$CONTAINER_HOME_DIR/.termuxrc:z
        VOLUME_repo_json=$REPOROOT/repo.json:$CONTAINER_HOME_DIR/termux-packages/repo.json:z
        VOLUME_tur=$REPOROOT/tur:$CONTAINER_HOME_DIR/termux-packages/tur:z
        VOLUME_disabled_tur=$REPOROOT/disabled-tur:$CONTAINER_HOME_DIR/termux-packages/disabled-tur:z
        VOLUME_common_files=$REPOROOT/common-files:$CONTAINER_HOME_DIR/termux-packages/common-files:z
        if [ ! -e $REPOROOT/output ];then mkdir $REPOROOT/output;fi
        VOLUME_output=$REPOROOT/output:$CONTAINER_HOME_DIR/termux-packages/output:z

else
	VOLUME_termux=$TERMUX_SCRIPTDIR:$CONTAINER_HOME_DIR/termux-packages
	VOLUME_termuxrc=$REPOROOT/termuxrc:$CONTAINER_HOME_DIR/.termuxrc
	VOLUME_repo_json=$REPOROOT/repo.json:$CONTAINER_HOME_DIR/termux-packages/repo.json
	VOLUME_tur=$REPOROOT/tur:$CONTAINER_HOME_DIR/termux-packages/tur
	VOLUME_disabled_tur=$REPOROOT/disabled-tur:$CONTAINER_HOME_DIR/termux-packages/disabled-tur
	VOLUME_common_files=$REPOROOT/common-files:$CONTAINER_HOME_DIR/termux-packages/common-files
	if [ ! -e $REPOROOT/output ];then mkdir $REPOROOT/output;fi
	VOLUME_output=$REPOROOT/output:$CONTAINER_HOME_DIR/termux-packages/output
fi

: ${TERMUX_BUILDER_IMAGE_NAME:=ghcr.io/termux/package-builder}
: ${CONTAINER_NAME:=termux-package-builder-tur}

USER=builder

if [ -n "${TERMUX_DOCKER_USE_SUDO-}" ]; then
	SUDO="sudo"
else
	SUDO=""
fi

echo "Running container '$CONTAINER_NAME' from image '$TERMUX_BUILDER_IMAGE_NAME'..."

# Check whether attached to tty and adjust docker flags accordingly.
if [ -t 1 ]; then
	DOCKER_TTY=" --tty"
else
	DOCKER_TTY=""
fi

$SUDO docker start $CONTAINER_NAME >/dev/null 2>&1 || {
	echo "Creating new container..."
	$SUDO docker run \
		--detach \
		--init \
		--name $CONTAINER_NAME \
		--volume $VOLUME_termux \
		--volume $VOLUME_termuxrc \
		--volume $VOLUME_VOLUME_repo_json \
		--volume $VOLUME_tur \
		--volume $VOLUME_disabled_tur \
		--volume $VOLUME_common_files \
		--volume $VOLUME_output \
		$SEC_OPT \
		--tty \
		$TERMUX_BUILDER_IMAGE_NAME
	if [ "$UNAME" != Darwin ]; then
		if [ $(id -u) -ne 1001 -a $(id -u) -ne 0 ]; then
			echo "Changed builder uid/gid... (this may take a while)"
			$SUDO docker exec $DOCKER_TTY $CONTAINER_NAME sudo chown -R $(id -u) $CONTAINER_HOME_DIR
			$SUDO docker exec $DOCKER_TTY $CONTAINER_NAME sudo chown -R $(id -u) /data
			$SUDO docker exec $DOCKER_TTY $CONTAINER_NAME sudo usermod -u $(id -u) builder
			$SUDO docker exec $DOCKER_TTY $CONTAINER_NAME sudo groupmod -g $(id -g) builder
		fi
	fi
}

# Set traps to ensure that the process started with docker exec and all its children are killed. 
. "$TERMUX_SCRIPTDIR/scripts/utils/docker/docker.sh"; docker__setup_docker_exec_traps

if [ "$#" -eq  "0" ]; then
	$SUDO docker exec --env "DOCKER_EXEC_PID_FILE_PATH=$DOCKER_EXEC_PID_FILE_PATH" --interactive $DOCKER_TTY $CONTAINER_NAME bash
else
	$SUDO docker exec --env "DOCKER_EXEC_PID_FILE_PATH=$DOCKER_EXEC_PID_FILE_PATH" --interactive $DOCKER_TTY $CONTAINER_NAME "$@"
fi
