#!/bin/bash
set -e

export TARGET=x86_64-linux-android
export TARGET_JDK=x86_64
export NDK_PREBUILT_ARCH=/toolchains/x86_64-4.9/prebuilt/linux-x86_64/x86_64-linux-android/bin/strip

bash "$TERMUX_PKG_BUILDER_DIR/ci_build_global.sh"

