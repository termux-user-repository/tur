TERMUX_PKG_HOMEPAGE=https://github.com/AndreRH/FEX
TERMUX_PKG_DESCRIPTION="x86 and x86-64 Linux emulator library for Hangover"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=8.17
TERMUX_PKG_SRCURL=git+https://github.com/AndreRH/FEX
TERMUX_PKG_GIT_BRANCH="hangover-8.17"
TERMUX_PKG_DEPENDS="libandroid-shmem, libc++"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_BUILD_TYPE=RelWithDebInfo
-DBUILD_TESTS=OFF
-DENABLE_LTO=OFF
-DENABLE_JEMALLOC=OFF
-DENABLE_JEMALLOC_GLIBC_ALLOC=OFF
-DENABLE_OFFLINE_TELEMETRY=OFF
-DENABLE_TERMUX_BUILD=True
-DTUNE_CPU=generic
-DTUNE_ARCH=armv8-a
"
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686, x86_64"

TERMUX_PKG_HOSTBUILD=true

termux_step_post_get_source() {
	# Remove this marker all the time
	rm -rf $TERMUX_HOSTBUILD_MARKER
}

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
	termux_setup_cmake

	# Setup llvm-mingw toolchain
	_setup_llvm_mingw_toolchain

	# Make fex wow64 dlls
	cmake -DCMAKE_TOOLCHAIN_FILE=$TERMUX_PKG_SRCDIR/toolchain_mingw.cmake \
			-DENABLE_JEMALLOC=0 -DENABLE_JEMALLOC_GLIBC_ALLOC=0 \
			-DMINGW_TRIPLE=aarch64-w64-mingw32 \
			-DCMAKE_BUILD_TYPE=RelWithDebInfo \
			-DBUILD_TESTS=False \
			-DENABLE_ASSERTIONS=False \
			$TERMUX_PKG_SRCDIR

	make -j $TERMUX_MAKE_PROCESSES -k wow64fex || bash
}

termux_step_pre_configure() {
	find $TERMUX_PKG_SRCDIR -name '*.h' -o -name '*.c' -o -name '*.cpp' | \
		xargs -n 1 sed -i -e 's:"/tmp:"'$TERMUX_PREFIX'/tmp:g'
}

termux_step_make() {
	ninja -j $TERMUX_MAKE_PROCESSES -k 0 FEXCore_shared || bash
}

termux_step_make_install() {
	# Install libfexcore
	cp $TERMUX_PKG_BUILDDIR/FEXCore/Source/libFEXCore.so $TERMUX_PREFIX/lib/

	# Install WOW64Fex
	mkdir -p $TERMUX_PREFIX/lib/wine/aarch64-windows
	cp $TERMUX_PKG_HOSTBUILD_DIR/Bin/libwow64fex.dll $TERMUX_PREFIX/lib/wine/aarch64-windows/
	# Patch dll to be picked up by wineboot
	# https://github.com/termux-user-repository/tur/issues/749#issuecomment-1871500069
	echo -n "Wine builtin DLL" > /tmp/builtin.template.1
	dd if=/dev/zero of=/tmp/builtin.template.2 bs=16 count=1
	cat /tmp/builtin.template.1 /tmp/builtin.template.2 > /tmp/builtin.template
	dd if=/tmp/builtin.template of=$TERMUX_PREFIX/lib/wine/aarch64-windows/libwow64fex.dll bs=32 count=1 seek=2 conv=notrunc
}
