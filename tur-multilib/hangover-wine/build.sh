TERMUX_PKG_HOMEPAGE=https://github.com/AndreRH/wine
TERMUX_PKG_DESCRIPTION="A compatibility layer for running Windows programs (Hangover forked)"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_LICENSE_FILE="\
LICENSE
LICENSE.OLD
COPYING.LIB"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
# FIXME: See comments at the end of this file for the reason why this version is used.
TERMUX_PKG_VERSION=8.17
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/AndreRH/wine/archive/refs/tags/hangover-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=f4d94572c28ab36a8a4355e8d661a4f2bfe903d2e2b3e977f400c16f7bfad556
TERMUX_PKG_DEPENDS="libandroid-spawn, libc++, libgmp, libgnutls"
TERMUX_PKG_BUILD_DEPENDS="libandroid-spawn-static"
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS="
--without-x
--disable-tests
"

TERMUX_PKG_BREAKS="wine-devel, wine-stable, wine-staging"
TERMUX_PKG_CONFLICTS="wine-devel, wine-stable, wine-staging"

TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686, x86_64"

# TODO: Enable X
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
enable_wineandroid_drv=no
exec_prefix=$TERMUX_PREFIX
--prefix=$TERMUX_PREFIX
--libdir=$TERMUX_PREFIX/lib
--sbindir=$TERMUX_PREFIX/bin
--without-x
--without-vulkan
--with-wine-tools=$TERMUX_PKG_HOSTBUILD_DIR
--enable-nls
--disable-tests
--enable-win64
--with-mingw
--enable-archs=i386,arm,aarch64
"

_setup_llvm_mingw_toolchain() {
	# LLVM-mingw's version number must not be the same as the NDK's.
	local _llvm_mingw_version=16
	local _version="20230614"
	local _url="https://github.com/mstorsjo/llvm-mingw/releases/download/$_version/llvm-mingw-$_version-ucrt-ubuntu-20.04-x86_64.tar.xz"
	local _path="$TERMUX_PKG_CACHEDIR/$(basename $_url)"
	local _sha256sum=9ae925f9b205a92318010a396170e69f74be179ff549200e8122d3845ca243b8
	termux_download $_url $_path $_sha256sum
	local _extract_path="$TERMUX_PKG_CACHEDIR/llvm-mingw-toolchain-$_llvm_mingw_version"
	if [ ! -d "$_extract_path" ]; then
		mkdir -p "$_extract_path"-tmp
		tar -C "$_extract_path"-tmp --strip-component=1 -xf "$_path"
		mv "$_extract_path"-tmp "$_extract_path"
	fi
	export PATH="$PATH:$_extract_path/bin"
}

termux_step_host_build() {
	# Setup llvm-mingw toolchain
	_setup_llvm_mingw_toolchain

	# Make host wine-tools
	(unset sudo; sudo apt update; sudo apt install libfreetype-dev:i386 -yqq)
	"$TERMUX_PKG_SRCDIR/configure" ${TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS}
	make -j "$TERMUX_MAKE_PROCESSES" __tooldeps__ nls/all
}

termux_step_pre_configure() {
	# Setup llvm-mingw toolchain
	_setup_llvm_mingw_toolchain

	# Fix overoptimization
	CPPFLAGS="${CPPFLAGS/-Oz/}"
	CFLAGS="${CFLAGS/-Oz/}"
	CXXFLAGS="${CXXFLAGS/-Oz/}"

	LDFLAGS+=" -landroid-spawn"
}

termux_step_make() {
	make -j $TERMUX_MAKE_PROCESSES || bash
}

termux_step_make_install() {
	make -j $TERMUX_MAKE_PROCESSES install || bash
}

# FIXME: Wine is broken since commit 25db1c5d49dc339e9b5a25514c198a524bd05484,
# FIXME: (wine-devel-8.17-39-g25db1c5d49d), simply reverting that patch will 
# FIXME: break other functions, maybe this should be reported upstream.
# `WINEDEBUG=+all wine a.exe`
# ```
# 0027d000,checksum=00000000}, name=L"\\??\\C:\\windows\\system32\\ntdll.dll" }
# 002c: get_handle_fd( handle=0014 )
# 002c: *fd* 0014 -> 31
# 002c: get_handle_fd() = 0 { type=1, cacheable=1, access=000f000d, options=00000020 }
# 002c: get_image_map_address( handle=0014 )
# 002c: get_image_map_address() = 0 { addr=6fffffd90000 }
# 428222.269:0028:002c:trace:virtual:try_map_free_area Found free area is already mapped, start 0xffffffd80000.
# 428222.269:0028:002c:trace:virtual:try_map_free_area Found free area is already mapped, start 0xffffffd70000.
# 428222.269:0028:002c:trace:virtual:try_map_free_area Found free area is already mapped, start 0xffffffd60000.
# 428222.269:0028:002c:trace:virtual:try_map_free_area Found free area is already mapped, start 0xffffffd50000.
# 428222.269:0028:002c:trace:virtual:try_map_free_area Found free area is already mapped, start 0xffffffd40000.
# ```
