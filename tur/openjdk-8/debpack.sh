#!/bin/bash
set -e

## Usage:
## Run after removejdkdebuginfo.sh (jdkout/${TARGET_SHORT}/ must exist)
## ./debpack.sh [output_directory]

. "$TERMUX_PKG_BUILDER_DIR/setdevkitpath.sh"

out="${1:-debout}"
mkdir -p "$out"

# Detect arch directory inside jdkout/${TARGET_SHORT}/lib/ (e.g., aarch64, i386, amd64, arm)
JDK_LIB_ARCH=$(ls -d jdkout/${TARGET_SHORT}/lib/*/ 2>/dev/null | head -1 | xargs basename)
echo "Detected JDK lib arch directory: $JDK_LIB_ARCH"

# Map OpenJDK arch name → Debian architecture name
case "$JDK_LIB_ARCH" in
  aarch32) DEB_ARCH=arm     ;;
  aarch64) DEB_ARCH=aarch64 ;;
  i386)    DEB_ARCH=i686    ;;
  amd64)   DEB_ARCH=x86_64  ;;
  *)       echo "Unknown arch directory: $JDK_LIB_ARCH"; exit 1 ;;
esac

JVM_DIR=/data/data/com.termux/files/usr/lib/jvm/java-8-openjdk
DEB_DATA_DIR=debdata/data/data/com.termux/files/usr/lib/jvm/java-8-openjdk
DEB_CTRL_DIR=debdata/DEBIAN

# Extract version from jdkout/${TARGET_SHORT}/release
JAVA_VERSION=$(grep -oP 'JAVA_VERSION="\K[^"]+' jdkout/${TARGET_SHORT}/release 2>/dev/null || echo "1.8.0")
JAVA_FULL_VERSION=$(grep -oP 'JAVA_FULL_VERSION="\K[^"]+' jdkout/${TARGET_SHORT}/release 2>/dev/null || echo "$JAVA_VERSION")
VERSION=$(echo "$JAVA_FULL_VERSION" | sed 's/1\.8\.0_\([0-9]*\)/\1/' | sed 's/1\.8\.0/0/')
DEB_VERSION="8.0.${VERSION:-$(date +%Y%m%d)}"
INSTALLED_SIZE=$(du -sk jdkout/${TARGET_SHORT} | cut -f1)

# Build termux-elf-cleaner if not already built
if [ ! -f termux-elf-cleaner/build/termux-elf-cleaner ]; then
  echo "Building termux-elf-cleaner..."
  unset AR AS CC CXX LD OBJCOPY RANLIB STRIP CPPFLAGS LDFLAGS
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

# Clean up and prepare directories
rm -rf debdata
mkdir -p "$DEB_DATA_DIR"
mkdir -p "$DEB_CTRL_DIR"

# Copy jdkout content
cp -a jdkout/${TARGET_SHORT}/* "$DEB_DATA_DIR/"

# Apply jre_override (fonts, etc.)
if [ -d "$TERMUX_PKG_BUILDER_DIR/jre_override" ]; then
  cp -Rf "$TERMUX_PKG_BUILDER_DIR/jre_override/lib/"* "$DEB_DATA_DIR/jre/lib/" 2>/dev/null || true
fi

# Run termux-elf-cleaner on all ELF files
findexec() {
  find "$1" -type f -not -name "*.o" -exec sh -c '
    case "$(head -n 1 "$1")" in
      ?ELF*) exit 0;;
      MZ*) exit 0;;
    esac
    exit 1
  ' sh {} \; -print
}

echo "Cleaning ELF files with termux-elf-cleaner..."
findexec "$DEB_DATA_DIR" | xargs -- ./termux-elf-cleaner/build/termux-elf-cleaner || true

# Strip debug .diz files
find "$DEB_DATA_DIR" -name "*.diz" -delete 2>/dev/null || true

# Set RUNPATH on ELF binaries and shared libraries
RUNPATH="${JVM_DIR}/lib/${JDK_LIB_ARCH}:${JVM_DIR}/lib/${JDK_LIB_ARCH}/jli:${JVM_DIR}/jre/lib/${JDK_LIB_ARCH}:${JVM_DIR}/jre/lib/${JDK_LIB_ARCH}/jli:${JVM_DIR}/jre/lib/${JDK_LIB_ARCH}/${JVM_VARIANTS}:${JVM_DIR}/lib:${JVM_DIR}/jre/lib"
echo "Setting RUNPATH to: $RUNPATH"

# Set RUNPATH on all ELF files (shared libs + executables)
find "$DEB_DATA_DIR" -type f -name "*.so" -exec sh -c '
  case "$(head -n 1 "$1")" in ?ELF*) exit 0;; *) exit 1;; esac
' sh {} \; -exec patchelf --set-rpath "$RUNPATH" {} \; 2>/dev/null || true
find "$DEB_DATA_DIR" -type f ! -name "*.so" -exec sh -c '
  case "$(head -n 1 "$1")" in ?ELF*) exit 0;; *) exit 1;; esac
' sh {} \; -exec patchelf --set-rpath "$RUNPATH" {} \; 2>/dev/null || true

# Create librt.so symlinks to Android system libc
# On 64-bit: /system/lib64/libc.so, on 32-bit: /system/lib/libc.so
for dir in "$DEB_DATA_DIR/lib/${JDK_LIB_ARCH}" "$DEB_DATA_DIR/jre/lib/${JDK_LIB_ARCH}"; do
  if [ -f "$dir/librt.so" ]; then
    rm -f "$dir/librt.so"
  fi
  case "${JDK_LIB_ARCH}" in
    aarch64|amd64|x86_64) ln -sf /system/lib64/libc.so "$dir/librt.so" ;;
    *)                    ln -sf /system/lib/libc.so  "$dir/librt.so" ;;
  esac
done

# Fix libjsig.so symlink (relative)
for variant_dir in server client; do
  (cd "$DEB_DATA_DIR/jre/lib/${JDK_LIB_ARCH}/$variant_dir" && ln -sf ../libjsig.so libjsig.so) 2>/dev/null || true
done

# Create profile.d/java.sh
mkdir -p "$DEB_DATA_DIR/etc/profile.d"
echo "export JAVA_HOME=${JVM_DIR}/" > "$DEB_DATA_DIR/etc/profile.d/java.sh"

# Create DEBIAN/control
cat > "$DEB_CTRL_DIR/control" <<EOF
Package: openjdk-8
Architecture: ${DEB_ARCH}
Installed-Size: ${INSTALLED_SIZE}
Maintainer: @SrErikCoderx
Version: ${DEB_VERSION}
Homepage: https://openjdk.java.net
Depends: freetype
Recommends: fontconfig, ca-certificates-java, resolv-conf
Suggests: cups
Description: Java development kit and runtime
EOF

# Create DEBIAN/postinst with update-alternatives
cat > "$DEB_CTRL_DIR/postinst" <<'POSTINST'
#!/data/data/com.termux/files/usr/bin/sh
if [ "$1" = 'configure' ] || [ "$1" = 'abort-upgrade' ] || [ "$1" = 'abort-deconfigure' ] || [ "$1" = 'abort-remove' ]; then
  if [ -x "/data/data/com.termux/files/usr/bin/update-alternatives" ]; then
    update-alternatives \
      --install "/data/data/com.termux/files/usr/bin/java" "java" "/data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/java" 10 \
      --slave /data/data/com.termux/files/usr/bin/appletviewer appletviewer /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/appletviewer \
      --slave /data/data/com.termux/files/usr/bin/clhsdb clhsdb /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/clhsdb \
      --slave /data/data/com.termux/files/usr/bin/extcheck extcheck /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/extcheck \
      --slave /data/data/com.termux/files/usr/bin/hsdb hsdb /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/hsdb \
      --slave /data/data/com.termux/files/usr/bin/idlj idlj /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/idlj \
      --slave /data/data/com.termux/files/usr/bin/jar jar /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jar \
      --slave /data/data/com.termux/files/usr/bin/jarsigner jarsigner /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jarsigner \
      --slave /data/data/com.termux/files/usr/bin/java-rmi.cgi java-rmi.cgi /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/java-rmi.cgi \
      --slave /data/data/com.termux/files/usr/bin/javac javac /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/javac \
      --slave /data/data/com.termux/files/usr/bin/javadoc javadoc /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/javadoc \
      --slave /data/data/com.termux/files/usr/bin/javah javah /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/javah \
      --slave /data/data/com.termux/files/usr/bin/javap javap /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/javap \
      --slave /data/data/com.termux/files/usr/bin/jcmd jcmd /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jcmd \
      --slave /data/data/com.termux/files/usr/bin/jconsole jconsole /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jconsole \
      --slave /data/data/com.termux/files/usr/bin/jdb jdb /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jdb \
      --slave /data/data/com.termux/files/usr/bin/jdeps jdeps /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jdeps \
      --slave /data/data/com.termux/files/usr/bin/jfr jfr /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jfr \
      --slave /data/data/com.termux/files/usr/bin/jhat jhat /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jhat \
      --slave /data/data/com.termux/files/usr/bin/jinfo jinfo /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jinfo \
      --slave /data/data/com.termux/files/usr/bin/jjs jjs /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jjs \
      --slave /data/data/com.termux/files/usr/bin/jmap jmap /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jmap \
      --slave /data/data/com.termux/files/usr/bin/jps jps /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jps \
      --slave /data/data/com.termux/files/usr/bin/jrunscript jrunscript /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jrunscript \
      --slave /data/data/com.termux/files/usr/bin/jsadebugd jsadebugd /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jsadebugd \
      --slave /data/data/com.termux/files/usr/bin/jstack jstack /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jstack \
      --slave /data/data/com.termux/files/usr/bin/jstat jstat /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jstat \
      --slave /data/data/com.termux/files/usr/bin/jstatd jstatd /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/jstatd \
      --slave /data/data/com.termux/files/usr/bin/keytool keytool /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/keytool \
      --slave /data/data/com.termux/files/usr/bin/native2ascii native2ascii /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/native2ascii \
      --slave /data/data/com.termux/files/usr/bin/orbd orbd /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/orbd \
      --slave /data/data/com.termux/files/usr/bin/pack200 pack200 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/pack200 \
      --slave /data/data/com.termux/files/usr/bin/policytool policytool /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/policytool \
      --slave /data/data/com.termux/files/usr/bin/rmic rmic /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/rmic \
      --slave /data/data/com.termux/files/usr/bin/rmid rmid /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/rmid \
      --slave /data/data/com.termux/files/usr/bin/rmiregistry rmiregistry /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/rmiregistry \
      --slave /data/data/com.termux/files/usr/bin/schemagen schemagen /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/schemagen \
      --slave /data/data/com.termux/files/usr/bin/serialver serialver /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/serialver \
      --slave /data/data/com.termux/files/usr/bin/servertool servertool /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/servertool \
      --slave /data/data/com.termux/files/usr/bin/tnameserv tnameserv /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/tnameserv \
      --slave /data/data/com.termux/files/usr/bin/unpack200 unpack200 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/unpack200 \
      --slave /data/data/com.termux/files/usr/bin/wsgen wsgen /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/wsgen \
      --slave /data/data/com.termux/files/usr/bin/wsimport wsimport /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/wsimport \
      --slave /data/data/com.termux/files/usr/bin/xjc xjc /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/xjc \
      --slave /data/data/com.termux/files/usr/share/man/man1/appletviewer.1 appletviewer.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/appletviewer.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/extcheck.1 extcheck.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/extcheck.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/idlj.1 idlj.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/idlj.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jar.1 jar.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jar.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jarsigner.1 jarsigner.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jarsigner.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/java.1 java.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/java.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/javac.1 javac.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/javac.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/javadoc.1 javadoc.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/javadoc.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/javah.1 javah.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/javah.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/javap.1 javap.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/javap.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jcmd.1 jcmd.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jcmd.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jconsole.1 jconsole.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jconsole.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jdb.1 jdb.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jdb.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jdeps.1 jdeps.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jdeps.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jhat.1 jhat.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jhat.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jinfo.1 jinfo.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jinfo.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jjs.1 jjs.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jjs.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jmap.1 jmap.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jmap.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jps.1 jps.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jps.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jrunscript.1 jrunscript.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jrunscript.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jsadebugd.1 jsadebugd.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jsadebugd.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jstack.1 jstack.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jstack.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jstat.1 jstat.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jstat.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/jstatd.1 jstatd.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/jstatd.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/keytool.1 keytool.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/keytool.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/native2ascii.1 native2ascii.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/native2ascii.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/orbd.1 orbd.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/orbd.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/pack200.1 pack200.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/pack200.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/policytool.1 policytool.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/policytool.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/rmic.1 rmic.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/rmic.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/rmid.1 rmid.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/rmid.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/rmiregistry.1 rmiregistry.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/rmiregistry.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/schemagen.1 schemagen.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/schemagen.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/serialver.1 serialver.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/serialver.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/servertool.1 servertool.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/servertool.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/tnameserv.1 tnameserv.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/tnameserv.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/unpack200.1 unpack200.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/unpack200.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/wsgen.1 wsgen.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/wsgen.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/wsimport.1 wsimport.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/wsimport.1 \
      --slave /data/data/com.termux/files/usr/share/man/man1/xjc.1 xjc.1 /data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/man/man1/xjc.1 \
      --slave "$PREFIX/etc/profile.d/java.sh" "java-profile" "/data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/etc/profile.d/java.sh"
  fi
fi
POSTINST

# Create DEBIAN/prerm
cat > "$DEB_CTRL_DIR/prerm" <<'PRERM'
#!/data/data/com.termux/files/usr/bin/sh
if [ "$1" = 'remove' ] || [ "$1" != 'upgrade' ]; then
  if [ -x "/data/data/com.termux/files/usr/bin/update-alternatives" ]; then
    update-alternatives --remove "java" "/data/data/com.termux/files/usr/lib/jvm/java-8-openjdk/bin/java"
  fi
fi
PRERM

chmod 755 "$DEB_CTRL_DIR/postinst"
chmod 755 "$DEB_CTRL_DIR/prerm"

# Remove any .gitkeep or empty files that might interfere
find debdata -name '.git*' -delete 2>/dev/null || true

# Normalize permissions (skip DEBIAN control dir)
find debdata -type d ! -path 'debdata/DEBIAN/*' -exec chmod 755 {} \;
# Executables first, then remaining files
find debdata -type f ! -path 'debdata/DEBIAN/*' -perm /111 -exec chmod 755 {} \;
find debdata -type f ! -path 'debdata/DEBIAN/*' ! -perm /111 -exec chmod 644 {} \;

# Install md5sums
cd debdata
find . -type f ! -path './DEBIAN/*' -exec md5sum {} \; > DEBIAN/md5sums 2>/dev/null || true
chmod 644 DEBIAN/md5sums
cd ..

DEB_FILE="${out}/openjdk-8_${DEB_VERSION}_${DEB_ARCH}.deb"
echo "Building ${DEB_FILE}..."
dpkg-deb --build debdata "${DEB_FILE}"
rm -rf debdata
echo "Done! Package created: ${DEB_FILE}"
