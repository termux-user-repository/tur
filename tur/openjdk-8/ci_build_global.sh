#!/bin/bash
set -e
. "$TERMUX_PKG_BUILDER_DIR/setdevkitpath.sh"

export JDK_DEBUG_LEVEL=release

if [ ! -d "$NDK" ]; then
  wget -nv -O android-ndk-$NDK_VERSION-linux-x86_64.zip "https://dl.google.com/android/repository/android-ndk-$NDK_VERSION-linux-x86_64.zip"
  bash "$TERMUX_PKG_BUILDER_DIR/extractndk.sh"
else
  echo "NDK already extracted at $NDK, skipping download"
fi
bash "$TERMUX_PKG_BUILDER_DIR/maketoolchain.sh"

bash "$TERMUX_PKG_BUILDER_DIR/getlibs.sh"
bash "$TERMUX_PKG_BUILDER_DIR/buildlibs.sh"
bash "$TERMUX_PKG_BUILDER_DIR/clonejdk.sh"
bash "$TERMUX_PKG_BUILDER_DIR/buildjdk.sh"
bash "$TERMUX_PKG_BUILDER_DIR/removejdkdebuginfo.sh"
# bash "$TERMUX_PKG_BUILDER_DIR/tarjdk.sh"
bash "$TERMUX_PKG_BUILDER_DIR/debpack.sh" debout
