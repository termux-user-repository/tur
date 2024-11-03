TERMUX_PKG_HOMEPAGE=https://github.com/AndreRH/wine
TERMUX_PKG_DESCRIPTION="A compatibility layer for running Windows programs (Hangover fork)"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_LICENSE_FILE="LICENSE, LICENSE.OLD, COPYING.LIB"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=9.20
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/AndreRH/wine/archive/refs/tags/hangover-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=7007a864f927bb8c789e04c8b0c3cb24ab1ae3928eaca26c1325391243570dcd
TERMUX_PKG_DEPENDS="fontconfig, freetype, krb5, libandroid-spawn, libc++, libgmp, libgnutls, libxcb, libxcomposite, libxcursor, libxfixes, libxrender, mesa, opengl, pulseaudio, sdl2, vulkan-loader, xorg-xrandr"
TERMUX_PKG_ANTI_BUILD_DEPENDS="vulkan-loader"
TERMUX_PKG_BUILD_DEPENDS="libandroid-spawn-static, vulkan-loader-generic"
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS="
--without-x
--disable-tests
"

TERMUX_PKG_BREAKS="wine-devel, wine-stable, wine-staging"
TERMUX_PKG_CONFLICTS="wine-devel, wine-stable, wine-staging"

TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686, x86_64"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
enable_wineandroid_drv=no
exec_prefix=$TERMUX_PREFIX
--with-wine-tools=$TERMUX_PKG_HOSTBUILD_DIR
--enable-nls
--disable-tests
--without-alsa
--without-capi
--without-coreaudio
--without-cups
--without-dbus
--with-fontconfig
--with-freetype
--without-gettext
--with-gettextpo=no
--without-gphoto
--with-gnutls
--without-gstreamer
--without-inotify
--with-krb5
--with-mingw=clang
--without-netapi
--without-opencl
--with-opengl
--with-osmesa
--without-oss
--without-pcap
--with-pthread
--with-pulse
--without-sane
--with-sdl
--without-udev
--without-unwind
--without-usb
--without-v4l2
--with-vulkan
--with-xcomposite
--with-xcursor
--with-xfixes
--without-xinerama
--with-xinput
--with-xinput2
--with-xrandr
--with-xrender
--without-xshape
--without-xshm
--without-xxf86vm
--enable-archs=i386,aarch64,arm64ec
"
# TODO: `--enable-archs=arm` doesn't build with option `--with-mingw=clang`, but
# TODO: `arm64ec` doesn't build with option `--with-mingw` (arm64ec-w64-mingw32-clang)

_setup_llvm_mingw_toolchain() {
	# LLVM-mingw's version number must not be the same as the NDK's.
	local _llvm_mingw_version=19
	local _version="20240929"
	local _url="https://github.com/bylaws/llvm-mingw/releases/download/$_version/llvm-mingw-$_version-ucrt-ubuntu-20.04-x86_64.tar.xz"
	local _path="$TERMUX_PKG_CACHEDIR/$(basename $_url)"
	local _sha256sum=ce75ad076c87663fd4a77513e947252d97ce799a11926c1f3ac7afed1d6ab85c
	termux_download $_url $_path $_sha256sum
	local _extract_path="$TERMUX_PKG_CACHEDIR/llvm-mingw-toolchain-$_llvm_mingw_version"
	if [ ! -d "$_extract_path" ]; then
		mkdir -p "$_extract_path"-tmp
		tar -C "$_extract_path"-tmp --strip-component=1 -xf "$_path"
		mv "$_extract_path"-tmp "$_extract_path"
	fi
	export PATH="$_extract_path/bin:$PATH"
}

termux_step_host_build() {
	# Setup llvm-mingw toolchain
	_setup_llvm_mingw_toolchain

	# Make host wine-tools
	(unset sudo; sudo apt update; sudo apt install libfreetype-dev:i386 -yqq)
	"$TERMUX_PKG_SRCDIR/configure" ${TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS}
	make -j "$TERMUX_PKG_MAKE_PROCESSES" __tooldeps__ nls/all
}

termux_step_pre_configure() {
	# Setup llvm-mingw toolchain
	_setup_llvm_mingw_toolchain

	# Fix overoptimization
	CPPFLAGS="${CPPFLAGS/-Oz/}"
	CFLAGS="${CFLAGS/-Oz/}"
	CXXFLAGS="${CXXFLAGS/-Oz/}"

	# Disable hardening
	CPPFLAGS="${CPPFLAGS/-fstack-protector-strong/}"
	CFLAGS="${CFLAGS/-fstack-protector-strong/}"
	CXXFLAGS="${CXXFLAGS/-fstack-protector-strong/}"
	LDFLAGS="${LDFLAGS/-Wl,-z,relro,-z,now/}"

	LDFLAGS+=" -landroid-spawn"
}

termux_step_make() {
	make -j $TERMUX_PKG_MAKE_PROCESSES
}

termux_step_make_install() {
	make -j $TERMUX_PKG_MAKE_PROCESSES install
}
