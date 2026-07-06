#!/bin/bash
# https://github.com/termux/termux-packages/blob/master/disabled-packages/openjdk-9-jre-headless/build.sh
set -e

. "$TERMUX_PKG_BUILDER_DIR/setdevkitpath.sh"

wget https://downloads.sourceforge.net/project/freetype/freetype2/$BUILD_FREETYPE_VERSION/freetype-$BUILD_FREETYPE_VERSION.tar.gz
tar xf freetype-$BUILD_FREETYPE_VERSION.tar.gz

wget https://github.com/apple/cups/releases/download/v2.2.4/cups-2.2.4-source.tar.gz
tar xf cups-2.2.4-source.tar.gz

# wget https://sourceforge.net/projects/freemarker/files/freemarker/2.3.8/freemarker-2.3.8.tar.gz/download -O freemarker-2.3.8.tar.gz
# tar -xzf freemarker-2.3.8.tar.gz

rm cups-2.2.4-source.tar.gz freetype-$BUILD_FREETYPE_VERSION.tar.gz
# freemarker-2.3.8.tar.gz
