#!/usr/bin/env bash
set -e -u -o pipefail

REPO_DIR=$(cd "$(realpath "$(dirname "$0")")"; pwd)
TERMUX_BASE_DIR="/data/data/com.termux/files"
TERMUX_HOME="$TERMUX_BASE_DIR/home"
TERMUX_PREFIX="$TERMUX_BASE_DIR/usr"

: ${TERMUX_ARCH:=x86_64}

# Test if PACKAGE_TO_BUILD is set or not
echo "Package(s) to build: $PACKAGE_TO_BUILD"

ABI=
case $TERMUX_ARCH in
	aarch64)
		ABI="arm64-v8a"
	;;
	arm) 
		ABI="armeabi-v7a"
	;;
	i686) 
		ABI="x86"
	;;
	x86_64) 
		ABI="x86_64"
	;;
	*)
		echo "Invalid arch."
		exit 1
	;;
esac

# Get and install Termux APK
URL=https://github.com/termux/termux-app/releases/download/v0.118.0/termux-app_v0.118.0+github-debug_$ABI.apk
wget $URL
adb install -r -t -g $REPO_DIR/$(basename $URL)
rm -f $REPO_DIR/$(basename $URL)

# Start Termux
adb shell am start -n com.termux/com.termux.app.TermuxActivity

# Sleep 10s to ensure that Termux has been successfully started.
sleep 10

# Switch to root mode
adb root
sleep 10

# Use custom shell script to build packages
adb push ./common-files/run-as-termux.sh /data/local/tmp/run-as-termux.sh
adb shell chmod +x /data/local/tmp/run-as-termux.sh

# Push local git repository to AVD
TERMUX_APP_ID=$(adb shell /data/local/tmp/run-as-termux.sh id -u)
adb push $REPO_DIR $TERMUX_HOME/repo

# Build packages
adb shell /data/local/tmp/run-as-termux.sh login -c "cd $TERMUX_HOME/repo && ./build-package.sh -I $PACKAGE_TO_BUILD"

# Pull result
rm -rf ./output
adb pull $TERMUX_HOME/repo/output ./
