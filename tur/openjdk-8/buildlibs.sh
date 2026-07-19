#!/bin/bash
set -e
. "$TERMUX_PKG_BUILDER_DIR/setdevkitpath.sh"
cd freetype-$BUILD_FREETYPE_VERSION

echo "Building Freetype"

export PATH=$TOOLCHAIN/bin:$PATH
./configure \
    --host=$TARGET \
    --prefix=`pwd`/build_android-${TARGET_SHORT} \
    --without-zlib \
    --with-brotli=no \
    --with-png=no \
    --with-harfbuzz=no --without-bzip2 $EXTRA_ARGS \
    || error_code=$?
if [[ "$error_code" -ne 0 ]]; then
  echo "\n\nCONFIGURE ERROR $error_code , config.log:"
  cat config.log
  exit $error_code
fi

CFLAGS=-fno-rtti CXXFLAGS=-fno-rtti make -j4
make install
