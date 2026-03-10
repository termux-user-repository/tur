#!/bin/bash
set -euo pipefail

: ${TERMUX_BUILDER_IMAGE_NAME:="ghcr.io/termux-user-repository/termux-docker-android-7:$ARCH"}
: ${CONTAINER_NAME:="termux-$ARCH"}

CONTAINER_HOME_DIR=/data/data/com.termux/files/home
REPOROOT="$(dirname $(readlink -f "$0"))/../"

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

__change_container_pid_max() {
	echo "Changing /proc/sys/kernel/pid_max to 65535 for packages that need to run native executables using aosp-libs (for 32-bit architectures)"
	if [[ "$($SUDO docker exec $CONTAINER_NAME cat /proc/sys/kernel/pid_max)" -le 65535 ]]; then
		echo "No need to change /proc/sys/kernel/pid_max, current value is $($SUDO docker exec $DOCKER_TTY $CONTAINER_NAME cat /proc/sys/kernel/pid_max)"
	else
		# On kernel versions >= 6.14, the pid_max value is pid namespaced, so we need to set it in the container namespace instead of host.
		# But some distributions may backport the pid namespacing to older kernels, so we check whether it's effective by checking the value in the container after setting it.
		$SUDO docker run --privileged --entrypoint /entrypoint_root.sh --pid="container:$CONTAINER_NAME" --rm "$TERMUX_BUILDER_IMAGE_NAME" sh -c "echo 65535 | tee /proc/sys/kernel/pid_max > /dev/null" || :
		if [[ "$($SUDO docker exec $CONTAINER_NAME cat /proc/sys/kernel/pid_max)" -eq 65535 ]]; then
			echo "Successfully changed /proc/sys/kernel/pid_max for container namespace"
		else
			echo "Failed to change /proc/sys/kernel/pid_max for container, falling back to setting it on host..."
			if ( echo 65535 | sudo tee /proc/sys/kernel/pid_max >/dev/null ); then
				echo "Successfully changed /proc/sys/kernel/pid_max on host, but it may affect other processes on the host system"
			else
				echo "Failed to change /proc/sys/kernel/pid_max on host as well, some packages that need to run native executables using aosp-libs (for 32-bit architectures) may not work properly"
			fi
		fi
	fi
}

if ! $SUDO docker container inspect $CONTAINER_NAME > /dev/null 2>&1; then
	echo "Creating new container..."
	$SUDO docker run \
		--interactive \
		--detach \
		--name $CONTAINER_NAME \
		--volume $REPOROOT:$CONTAINER_HOME_DIR/termux-packages \
		--security-opt seccomp=unconfined \
		--pid=host \
		--tty \
		-w $CONTAINER_HOME_DIR/termux-packages \
		$TERMUX_BUILDER_IMAGE_NAME
	__change_container_pid_max
fi

if [[ "$($SUDO docker container inspect -f '{{ .State.Running }}' $CONTAINER_NAME)" == "false" ]]; then
	$SUDO docker start $CONTAINER_NAME >/dev/null 2>&1
	__change_container_pid_max
fi

if [ "$#" -eq  "0" ]; then
	$SUDO docker exec --interactive $DOCKER_TTY $CONTAINER_NAME /entrypoint.sh
else
	$SUDO docker exec --interactive $DOCKER_TTY $CONTAINER_NAME /entrypoint.sh "$@"
fi
