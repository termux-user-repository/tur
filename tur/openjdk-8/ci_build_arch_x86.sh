#!/bin/bash
set -e

export TARGET=i686-linux-android
export TARGET_JDK=x86
export NDK_PREBUILT_ARCH=/toolchains/x86-4.9/prebuilt/linux-x86_64/i686-linux-android/bin/strip

bash "$TERMUX_PKG_BUILDER_DIR/ci_build_global.sh"

