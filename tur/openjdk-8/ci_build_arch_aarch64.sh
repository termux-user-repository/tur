#!/bin/bash
set -e
export TARGET=aarch64-linux-android
export TARGET_JDK=aarch64
export NDK_PREBUILT_ARCH=/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/aarch64-linux-android/bin/strip

bash "$TERMUX_PKG_BUILDER_DIR/ci_build_global.sh"

