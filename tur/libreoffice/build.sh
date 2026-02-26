TERMUX_PKG_HOMEPAGE=https://www.libreoffice.org/
TERMUX_PKG_DESCRIPTION="Free cross-platform office suite, fresh version"
TERMUX_PKG_LICENSE="MPL-2.0, LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=26.2.0.3
TERMUX_PKG_SRCURL=https://download.documentfoundation.org/libreoffice/src/${TERMUX_PKG_VERSION%.*}/libreoffice-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=5b80ec8ed6726479e0f033c08c38f9df36fa20b15c575378d75ba0c373f15416
# Ref: https://gitlab.archlinux.org/archlinux/packaging/packages/libreoffice-fresh/-/blob/main/PKGBUILD?ref_type=heads
# TODO: to be added compared to Archlinux deps="libwpd, libwps, neon, nspr, redland, lpsolve, gcc-libs, sh, libvisio, libetonyek, libodfgen, libcdr, libmspub, nss, clucene, libpagemaker, libabw, libmwaw, libe-book, liblangtag, libexttextcat, liborcus, libcmis, libzmf, libnumbertext, libfreehand, libstaroffice, libepubgen, libqxp, box2d, expat, glib2, glibc, librevenge"
# TODO/FIXME: xdg-utils is unsafe for on device build
# TODO: add back qt6 after qmake6 are available
TERMUX_PKG_DEPENDS="which, bison, hunspell, python, pango, libjpeg-turbo, libxrandr, libhyphen, libgraphite, libicu, libxslt, libglvnd, poppler, harfbuzz-icu, hicolor-icon-theme, desktop-file-utils, shared-mime-info, libxinerama, cups, littlecms, libwebp, libtommath, libatomic-ops, xmlsec, gpgme, libepoxy, libzxing-cpp, fontconfig, openldap, zlib, libpng, freetype, libraptor2, libxml2, libcairo, libx11, boost, libtiff, libxext, openjpeg, dbus, glm, openssl, argon2, curl, libcurl, libcmis, clucene, librevenge, libepubgen, libwpd, libodfgen, libwps, libvisio, libcdr, libmspub, libnss, libpagemaker, libabw, libmwaw, libe-book, liblangtag, libexttextcat, liborcus, libzmf, libnumbertext, libfreehand, libstaroffice, libqxp, box2d, libexpat, glib, redland, libnspr, lpsolve, abseil-cpp"
TERMUX_PKG_BUILD_DEPENDS="boost-headers, gtk4, gtk3, qt6-qtbase, postgresql, unixodbc, mariadb, libc++"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--host=$TERMUX_ARCH-linux
--with-extra-buildid=$TERMUX_PKG_VERSION
--with-vendor=Termux
--enable-split-app-modules
--enable-release-build
CPLUS_INCLUDE_PATH=$TERMUX_PREFIX/include
SYSBASE=$TERMUX_PREFIX

--disable-avahi
--enable-dbus
--enable-evolution2
--enable-evolution2
--enable-gio
--enable-gtk3
--enable-gtk4
--disable-introspection
--enable-lto
--enable-openssl
--enable-odk
--enable-scripting-beanshell
--enable-scripting-javascript
--disable-dconf
--disable-report-builder
--enable-ext-wiki-publisher
--enable-ext-nlpsolver
--without-fonts
--with-system-libxml
--with-system-libcdr
--with-system-mdd
--without-myspell-dicts
--with-system-libvisio
--with-system-libcmis
--with-system-libmspub
--with-system-libexttextcat
--with-system-orcus
--with-system-liblangtag
--with-system-libodfgen
--with-system-libmwaw
--with-system-libetonyek
--with-system-libfreehand
--without-system-firebird
--with-system-zxing
--with-system-libtommath
--with-system-libatomic-ops
--with-system-libebook
--with-system-libabw
--with-system-dicts
--with-external-dict-dir=$TERMUX_PREFIX/share/hunspell
--with-external-hyph-dir=$TERMUX_PREFIX/share/hyphen
--with-system-beanshell
--with-system-cppunit
--with-system-graphite
--with-system-glm
--with-system-libnumbertext
--with-system-libwpg
--with-system-libwps
--with-system-redland
--with-system-libzmf 
--with-system-gpgmepp
--with-system-libstaroffice
--without-java
--with-ant-home=$TERMUX_PREFIX/share/ant
--with-system-boost
--with-system-icu
--with-system-cairo
--with-system-libs
--with-system-headers
--without-system-hsqldb
--without-junit
--with-system-clucene
--without-system-box2d
--without-system-dragonbox
--without-system-libfixmath
--without-system-frozen
--without-system-zxcvbn
--without-system-java-websocket
--with-system-rhino
--without-system-libeot
--without-system-afdko
--disable-dependency-tracking

--with-boost-date-time=boost_date_time
--with-boost-filesystem=boost_filesystem
--with-boost-iostreams=boost_iostreams
--with-boost-locale=boost_locale

--without-doxygen
--without-system-md4c
--without-system-fast-float
--without-system-sane
--disable-python
--without-system-mythes
--without-system-coinmp
--disable-sdremote-bluetooth
--disable-avmedia
--with-system-abseil
--disable-gtk3-kde5
--disable-kf5
--disable-kf6
--disable-qt5
--disable-qt6

--disable-ld
"

termux_step_pre_configure() {
    # Use pkg-config-wrapper
    mkdir -p $TERMUX_PKG_TMPDIR/pkg-config-wrapper-bin
	cat > $TERMUX_PKG_TMPDIR/pkg-config-wrapper-bin/pkg-config <<-HERE
#!/bin/sh

if [ "\$CROSS_COMPILING" = TRUE ]; then
    export PKG_CONFIG_PATH=
    export PKG_CONFIG_DIR=
    export PKG_CONFIG_LIBDIR=$PKG_CONFIG_LIBDIR
else
    unset PKG_CONFIG_PATH
    unset PKG_CONFIG_DIR
    unset PKG_CONFIG_LIBDIR
fi

exec /usr/bin/pkg-config "\$@"
	HERE
    chmod +x $TERMUX_PKG_TMPDIR/pkg-config-wrapper-bin/pkg-config
    export PATH="$TERMUX_PKG_TMPDIR/pkg-config-wrapper-bin:$PATH"

    # Use a dummy folder to make configure happy
    mkdir -p $TERMUX_PKG_TMPDIR/dummy-build
    export CFLAGS_FOR_BUILD="-I$TERMUX_PKG_TMPDIR/dummy-build"
    export CPPFLAGS_FOR_BUILD="-I$TERMUX_PKG_TMPDIR/dummy-build"
    export CXXFLAGS_FOR_BUILD="-I$TERMUX_PKG_TMPDIR/dummy-build"
    export LDFLAGS_FOR_BUILD="-L$TERMUX_PKG_TMPDIR/dummy-build"
}

termux_step_configure() {
	if [ "$TERMUX_CONTINUE_BUILD" == "true" ]; then
		termux_step_pre_configure
		cd $TERMUX_PKG_SRCDIR
        return
	fi

    termux_step_configure_autotools
}

termux_step_make() {
    make -j $(nproc) || bash
}
