#!/bin/bash
set -e
# Extract the correct OpenJDK source tarball based on architecture.
# Tarballs are pre-downloaded by termux_step_get_source() into $TERMUX_PKG_CACHEDIR.
# TERMUX_PKG_CACHEDIR and TARGET_JDK are exported by build.sh.

rm -rf openjdk
mkdir -p openjdk

if [[ "$TARGET_JDK" == "arm" ]]; then
  tar xf "$TERMUX_PKG_CACHEDIR"/15ef9f9fc3e1ef61d253fe87500223e240be2052.tar.gz \
    -C openjdk --strip-components=1
else
  tar xf "$TERMUX_PKG_CACHEDIR"/40657cfd8c0ba65a3402b27dab49cca1dbc3696f.tar.gz \
    -C openjdk --strip-components=1
fi
