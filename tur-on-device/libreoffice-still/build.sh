TERMUX_PKG_HOMEPAGE=https://www.libreoffice.org/
TERMUX_PKG_DESCRIPTION="LibreOffice branch which contains new features and program enhancements"
TERMUX_PKG_LICENSE="MPL-2.0, LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=24.2.6.2
TERMUX_PKG_SRCURL=https://download.documentfoundation.org/libreoffice/src/${TERMUX_PKG_VERSION%.*}/libreoffice-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=f6ea4df022696065b5dcdca4e28bf06906ac852df4ba6dc50aa8fe59c8e11db3
TERMUX_PKG_DEPENDS="mdds, which, bison, hunspell, python, pango, libjpeg-turbo, libxrandr, libhyphen, libgraphite, libicu, libxslt, libglvnd, poppler, harfbuzz-icu, hicolor-icon-theme, desktop-file-utils, shared-mime-info, libxinerama, cups, littlecms, libwebp, libtommath, libatomic-ops, xmlsec, gpgme, libepoxy, libzxing-cpp, fontconfig, openldap, zlib, libpng, freetype, libraptor2, libxml2, libcairo, libx11, boost, libtiff, libxext, openjpeg, dbus, glm, openssl, argon2, curl, libcurl, libwpd, libwps, libneon, libnspr, redland, lpsolve, libvisio, libetonyek, libodfgen, libcdr, libmspub, libnss, clucene, libpagemaker, libabw, libmwaw, libe-book, liblangtag, libexttextcat, liborcus, libcmis, libzmf, libnumbertext, libfreehand, libstaroffice, libepubgen, libqxp, libexpat, librevenge, libwpg, xsltproc, libxml2-utils, libtommath-static, gobject-introspection, g-ir-scanner"
TERMUX_PKG_BUILD_DEPENDS="cppunit, gtk4, gtk3, qt6-qtbase, postgresql, unixodbc, mariadb, boost, boost-headers, icu-devtools, openjdk-17, openjdk-17-x, ant"
TERMUX_PKG_RECOMMENDS="openjdk-17, openjdk-17-x, gtk4, gtk3, qt6-qtbase, qt6-qtmultimedia"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"
# Ref: https://gitlab.archlinux.org/archlinux/packaging/packages/libreoffice-still/-/blob/main/PKGBUILD?ref_type=heads

# TODO: patch and remove TERMUX_PKG_BLACKLISTED_ARCHES
# TODO: remove --disable-skia, some vulkan related compilation error I couldn't solve.
# TODO: add back qt6-qtmultimedia, which currently breaks tur-on-device building by installing subpackage of deps and conflicting woth other deps.
# TODO: see if we want to add back qt5-qtbase, qt5-qmake, qt5-qtx11extras, some qt5 compilation to be fix.
# TODO: see if we want to add junit pacakge for java unit test and remove --without-junit
# TODO: replace --enable-debug with --enable-release-build
# TODO: replace --without-system-xmlsec by --with-system-xmlsec whwn xmlsec-nss becomes available by PR

## Set variables for building on my phone:
# TERMUX_PREFIX="$PREFIX"
# TERMUX_ARCH="aarch64"
# TERMUX_HOST_PLATFORM="$TERMUX_ARCH-linux-android"
# TERMUX_PKG_MAKE_PROCESSES=0
# TERMUX_ON_DEVICE_BUILD="true"

# TERMUX_PKG_EXTRA_MAKE_ARGS="--trace"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-debug

--with-vendor=Termux
--enable-split-app-modules

CC=$TERMUX_HOST_PLATFORM-clang
CXX=$TERMUX_HOST_PLATFORM-clang++
--with-parallelism=$TERMUX_PKG_MAKE_PROCESSES
--host=$TERMUX_ARCH-linux

--disable-sdremote
--disable-sdremote-bluetooth

--enable-curl
--with-jdk-home=$TERMUX_PREFIX/lib/jvm/java-17-openjdk
--with-ant-home=$TERMUX_PREFIX/opt/ant
--without-junit
--without-webdav
--with-system-libcmis
--with-system-clucene
--without-system-xmlsec

--with-system-librevenge
--with-system-libodfgen
--with-system-libepubgen
--with-system-libvisio
--with-system-libwpd
--with-system-libwpg
--with-system-libwps
--with-system-libcdr
--with-system-libmspub
--with-system-libmwaw
--with-system-libetonyek
--with-system-libfreehand
--with-system-libebook
--with-system-libabw
--with-system-libpagemaker
--with-system-libqxp
--with-system-libzmf
--with-system-libstaroffice

--with-system-cppunit

--with-system-libtommath
--with-system-mdds
--without-system-dragonbox
--without-system-frozen
--without-system-libfixmath
--without-system-hsqldb
--without-system-sane
--with-system-orcus
--with-system-redland
--without-system-box2d
--without-system-zxcvbn
--with-system-libexttextcat
--without-system-mythes
--with-system-libnumbertext
--disable-gstreamer-1-0
--disable-avahi
--with-system-liblangtag

--disable-coinmp
--enable-dbus
--enable-qt6
--enable-gtk3
--enable-gtk4
--enable-introspection
--enable-openssl
--enable-python=system
--without-system-beanshell
--enable-scripting-beanshell
--enable-scripting-javascript
--with-system-gpgmepp
--disable-report-builder
--disable-dconf
--enable-ext-wiki-publisher
--enable-ext-nlpsolver
--without-fonts
--with-system-libxml
--without-myspell-dicts
--without-system-firebird
--with-system-zxing
--with-system-dicts
--with-external-dict-dir=$TERMUX_PREFIX/share/hunspell
--with-external-hyph-dir=$TERMUX_PREFIX/share/hyphen
--with-system-graphite
--with-system-glm
--with-system-boost
--with-system-icu
--with-system-cairo
--with-system-libs
--with-system-headers

--disable-skia
--disable-firebird-sdbc

--with-boost=$TERMUX_PREFIX
boost_cv_lib_tag=

--disable-online-update
--disable-breakpad
--disable-dependency-tracking
"

termux_step_pre_configure() {
	if [ "$TERMUX_ON_DEVICE_BUILD" = "true" ]; then
		termux-fix-shebang ./solenv/bin/*
	fi
	export CLUCENE_CFLAGS=" -std=c++11"
	export qt6_libexec_dirs="$TERMUX_PREFIX/lib/qt6"
	export LDFLAGS+=" -Wl,--undefined-version"
	NOCONFIGURE=1 ./autogen.sh
}

termux_step_make_install() {
	make distro-pack-install
}
