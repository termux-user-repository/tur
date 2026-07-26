#!/bin/bash
set -e

. "$TERMUX_PKG_BUILDER_DIR/setdevkitpath.sh"
  
if [ ! -d "$NDK/generated-toolchains/android-${TARGET_SHORT}-toolchain" ]; then
	$NDK/build/tools/make-standalone-toolchain.sh \
		--arch=${TARGET_SHORT} \
		--platform=android-21 \
		--install-dir=$NDK/generated-toolchains/android-${TARGET_SHORT}-toolchain
fi
cp "$TERMUX_PKG_BUILDER_DIR/devkit.info.${TARGET_SHORT}" "$NDK/generated-toolchains/android-${TARGET_SHORT}-toolchain/"
