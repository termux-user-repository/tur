#!/bin/bash
set -e

unset AR AS CC CXX LD OBJCOPY RANLIB STRIP CPPFLAGS LDFLAGS
if [ ! -f termux-elf-cleaner/build/termux-elf-cleaner ]; then
  rm -rf termux-elf-cleaner
  git clone --depth 1 https://github.com/termux/termux-elf-cleaner
  cd termux-elf-cleaner
  mkdir -p build
  cd build
  export CFLAGS=-D__ANDROID_API__=${API}
  cmake ..
  make -j4
  unset CFLAGS
  cd ../..
fi

findexec() { find $1 -type f -name "*" -not -name "*.o" -exec sh -c '
    case "$(head -n 1 "$1")" in
      ?ELF*) exit 0;;
      MZ*) exit 0;;
      #!*/ocamlrun*)exit0;;
    esac
exit 1
' sh {} \; -print
}

findexec jreout/${TARGET_SHORT} | xargs -- ./termux-elf-cleaner/build/termux-elf-cleaner
findexec jdkout/${TARGET_SHORT} | xargs -- ./termux-elf-cleaner/build/termux-elf-cleaner

cp -Rf "$TERMUX_PKG_BUILDER_DIR/jre_override/lib/"* jreout/${TARGET_SHORT}/lib/
cp -Rf "$TERMUX_PKG_BUILDER_DIR/jre_override/lib/"* jdkout/${TARGET_SHORT}/jre/lib/

# Strip in place all .so files thanks to the ndk
find jreout/${TARGET_SHORT} -name '*.so' -exec ${NDK}${NDK_PREBUILT_ARCH} {} \; 2>/dev/null || true
find jdkout/${TARGET_SHORT} -name '*.so' -exec ${NDK}${NDK_PREBUILT_ARCH} {} \; 2>/dev/null || true

tar cJf jre8-${TARGET_SHORT}-`date +%Y%m%d`-${JDK_DEBUG_LEVEL}.tar.xz -C jreout/${TARGET_SHORT} .

tar cJf jdk8-${TARGET_SHORT}-`date +%Y%m%d`-${JDK_DEBUG_LEVEL}.tar.xz -C jdkout/${TARGET_SHORT} .

