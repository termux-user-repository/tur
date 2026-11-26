#!/usr/bin/env bash
set -e -u -o pipefail

REPO_DIR=$(cd "$(realpath "$(dirname "$0")")"; pwd)
TERMUX_BASE_DIR="/data/data/com.termux/files"
TERMUX_HOME="$TERMUX_BASE_DIR/home"
TERMUX_PREFIX="$TERMUX_BASE_DIR/usr"

: ${TERMUX_ARCH:=x86_64}
: ${TERMUX_VERSION:=0.118.1}

# Test if PACKAGE_TO_BUILD is set or not
echo "Package(s) to build: $PACKAGE_TO_BUILD"

# Enter workspace dir
export __log_dir="$(mktemp -d)"
cd "$__log_dir"

__start_waydroid() {
	echo "Starting mutter..."
	mutter --wayland --headless > mutter.out 2> mutter.err &
	echo "Starting pulseaudio..."
	pulseaudio --start --exit-idle-time=-1
	echo "Starting waydroid..."
	sudo sed -i 's|^\(\[properties\]\)$|\1\nro.hardware.gralloc=default|g' /var/lib/waydroid/waydroid.cfg
	sudo sed -i 's|^\(\[properties\]\)$|\1\nro.hardware.egl=swiftshader|g' /var/lib/waydroid/waydroid.cfg
	sudo sed -i 's|^\(\[properties\]\)$|\1\npersist.waydroid.suspend=false|g' /var/lib/waydroid/waydroid.cfg
	sudo waydroid upgrade -o
	waydroid session start > waydroid-session-start.out 2> waydroid-session-start.err &
	waydroid show-full-ui
	echo "Sleep 30s..."
	sleep 30
	echo "Test waydroid network"
	sudo waydroid shell -- curl -v https://www.google.com
}

__install_termux() {
	local version="$TERMUX_VERSION"
	local abi=
	case $TERMUX_ARCH in
		aarch64)
			abi="arm64-v8a"
		;;
		arm) 
			abi="armeabi-v7a"
		;;
		i686) 
			abi="x86"
		;;
		x86_64) 
			abi="x86_64"
		;;
		*)
			echo "Invalid arch."
			exit 1
		;;
	esac
	local url="https://github.com/termux/termux-app/releases/download/v$version/termux-app_v$version+github-debug_$abi.apk"
	wget $url
	waydroid app install $__log_dir/$(basename $url)
	sleep 10
	rm -f $__log_dir/$(basename $url)
}

__check_file_exists() {
	local path="$1"
	local counter=0
	local maxcnt=100
	while ! [ $(sudo waydroid shell -- run-as com.termux sh -c '[ -e "$1" ]; echo $?' - "$path") = 0 ]; do
		sleep 10s
		counter=$[counter+1]
		echo "Wait $counter time(s) for $path exists"
		if [ "$counter" = "$maxcnt" ]; then
			echo "Max counter reached"
			exit 1
		fi
	done
}

__prepare_sshd() {
	# Start Termux
	waydroid app launch com.termux
	# Check until $PREFIX exists
	__check_file_exists "$TERMUX_PREFIX"
	# OK. Now we have Termux bootstrap installed. Kill Termux now
	sudo waydroid shell -- am force-stop com.termux
	sleep 5
	# Install openssh in Termux
	sudo waydroid shell -- run-as com.termux sh -c "echo 'apt update && touch 1 && apt dist-upgrade -o Dpkg::Options::=--force-confnew -y && touch 2 && apt update && touch 3 && apt install openssh -yqq && touch 4' > $TERMUX_HOME/.bashrc"
	sudo waydroid shell -- am start -n com.termux/com.termux.app.TermuxActivity
	__check_file_exists $TERMUX_HOME/1
	__check_file_exists $TERMUX_HOME/2
	__check_file_exists $TERMUX_HOME/3
	__check_file_exists $TERMUX_HOME/4
	# Generate ssh-key for Termux
	ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
	public_key="$(cat ~/.ssh/id_rsa.pub)"
	# Add ssh-key to Termux's authorized_keys
	sudo waydroid shell -- run-as com.termux sh -c "echo '$public_key' >> $TERMUX_HOME/.ssh/authorized_keys"
	# Start sshd in Termux
	sudo waydroid shell -- run-as com.termux sh -c "echo 'sshd' > $TERMUX_HOME/.bashrc"
	sudo waydroid shell -- am force-stop com.termux
	sleep 5
	sudo waydroid shell -- am start -n com.termux/com.termux.app.TermuxActivity
	sleep 5
}

__build_package() {
	# Get IP address of Waydroid container
	waydroid_ip="$(waydroid status | grep -oP 'IP address:\s+\K[\d.]+')"
	# Execute `ls -al` with ssh for testing
	ssh -o StrictHostKeyChecking=no "$waydroid_ip" -p 8022 -- ls -al
	# Connect to Waydroid connect with adb
	scp -r -o StrictHostKeyChecking=no -P 8022 $REPO_DIR/ "$waydroid_ip":$TERMUX_HOME/repo

	# Build packages
	ssh -o StrictHostKeyChecking=no "$waydroid_ip" -p 8022 -- "cd $TERMUX_HOME/repo && ./scripts/setup-termux.sh"
	ssh -o StrictHostKeyChecking=no "$waydroid_ip" -p 8022 -- "cd $TERMUX_HOME/repo && ./build-package.sh -I $PACKAGE_TO_BUILD"

	# Pull result
	rm -rf ./output
	scp -r -o StrictHostKeyChecking=no $TERMUX_HOME/repo/output "$waydroid_ip":$REPO_DIR/ -p 8022
}

__start_waydroid
__install_termux
__prepare_sshd
__build_package
