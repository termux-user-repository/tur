#!/bin/bash
set -e
# Extract the correct OpenJDK source tarball based on architecture.
# Tarballs are pre-downloaded by termux_step_get_source() into $TERMUX_PKG_CACHEDIR.
# TERMUX_PKG_CACHEDIR and TARGET_JDK are exported by build.sh.

rm -rf openjdk
mkdir -p openjdk

if [[ "$TARGET_JDK" == "arm" ]]; then
  tar xf "$TERMUX_PKG_CACHEDIR"/aarch32.tar.gz \
    -C openjdk --strip-components=1
else
  tar xf "$TERMUX_PKG_CACHEDIR"/jdk8u.tar.gz \
    -C openjdk --strip-components=1
fi
