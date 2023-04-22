TERMUX_PKG_HOMEPAGE=https://nodejs.org/
TERMUX_PKG_DESCRIPTION="Open Source, cross-platform JavaScript runtime environment"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=16.20.0
TERMUX_PKG_SRCURL=https://nodejs.org/dist/v${TERMUX_PKG_VERSION}/node-v${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=e0990f992234e40a51fe11f92c3816c93a77e1b081145d3dd762cd1026345349
# Note that we do not use a shared libuv to avoid an issue with the Android
# linker, which does not use symbols of linked shared libraries when resolving
# symbols on dlopen(). See https://github.com/termux/termux-packages/issues/462.
#
# Node.js 16.x does not support `NODE_OPTIONS=--openssl-legacy-provider` option.
# See https://github.com/termux/termux-packages/issues/9266. Please revert back
# to depending on openssl (instead of openssl-1.1) when migrating to next LTS.
TERMUX_PKG_DEPENDS="libc++, openssl-1.1, c-ares, libicu, zlib"
TERMUX_PKG_SUGGESTS="clang, make, pkg-config, python"
_INSTALL_PREFIX=opt/nodejs-16
TERMUX_PKG_RM_AFTER_INSTALL="
$_INSTALL_PREFIX/lib/node_modules/npm/html
$_INSTALL_PREFIX/lib/node_modules/npm/make.bat
$_INSTALL_PREFIX/share/systemtap
$_INSTALL_PREFIX/lib/dtrace
"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_HOSTBUILD=true

termux_step_post_get_source() {
	# Prevent caching of host build:
	rm -Rf $TERMUX_PKG_HOSTBUILD_DIR
}

termux_step_host_build() {
	local ICU_VERSION=73.1
	local ICU_TAR=icu4c-${ICU_VERSION//./_}-src.tgz
	local ICU_DOWNLOAD=https://github.com/unicode-org/icu/releases/download/release-${ICU_VERSION//./-}/$ICU_TAR
	termux_download \
		$ICU_DOWNLOAD\
		$TERMUX_PKG_CACHEDIR/$ICU_TAR \
		a457431de164b4aa7eca00ed134d00dfbf88a77c6986a10ae7774fc076bb8c45
	tar xf $TERMUX_PKG_CACHEDIR/$ICU_TAR
	cd icu/source
	if [ "$TERMUX_ARCH_BITS" = 32 ]; then
		./configure --prefix $TERMUX_PKG_HOSTBUILD_DIR/icu-installed \
			--disable-samples \
			--disable-tests \
			--build=i686-pc-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
	else
		./configure --prefix $TERMUX_PKG_HOSTBUILD_DIR/icu-installed \
			--disable-samples \
			--disable-tests
	fi
	make -j $TERMUX_MAKE_PROCESSES install
}

termux_step_configure() {
	local DEST_CPU
	if [ $TERMUX_ARCH = "arm" ]; then
		DEST_CPU="arm"
	elif [ $TERMUX_ARCH = "i686" ]; then
		DEST_CPU="ia32"
	elif [ $TERMUX_ARCH = "aarch64" ]; then
		DEST_CPU="arm64"
	elif [ $TERMUX_ARCH = "x86_64" ]; then
		DEST_CPU="x64"
	else
		termux_error_exit "Unsupported arch '$TERMUX_ARCH'"
	fi

	export GYP_DEFINES="host_os=linux"
	export CC_host=gcc
	export CXX_host=g++
	export LINK_host=g++

	LDFLAGS+=" -ldl"

	# For pipe2
	CFLAGS+=" -D__USE_GNU=1"
	CPPFLAGS+=" -D__USE_GNU=1"
	CXXFLAGS+=" -D__USE_GNU=1"

	local _SHARED_OPENSSL_INCLUDES=$TERMUX_PREFIX/include
	local _SHARED_OPENSSL_LIBPATH=$TERMUX_PREFIX/lib

	if [ "${TERMUX_PKG_VERSION%%.*}" != "16" ]; then
		termux_error_exit 'Please migrate to using openssl (instead of openssl-1.1).'
	else
		_SHARED_OPENSSL_INCLUDES=$TERMUX_PREFIX/include/openssl-1.1
		_SHARED_OPENSSL_LIBPATH=$TERMUX_PREFIX/lib/openssl-1.1
		LDFLAGS="-Wl,-rpath=$_SHARED_OPENSSL_LIBPATH $LDFLAGS"
	fi

	mkdir -p $TERMUX_PREFIX/$_INSTALL_PREFIX
	LDFLAGS="-Wl,-rpath=$TERMUX_PREFIX/$_INSTALL_PREFIX/lib $LDFLAGS"

	# See note above TERMUX_PKG_DEPENDS why we do not use a shared libuv.
	./configure \
		--prefix=$TERMUX_PREFIX/$_INSTALL_PREFIX \
		--dest-cpu=$DEST_CPU \
		--dest-os=android \
		--shared-cares \
		--shared-openssl \
		--shared-openssl-includes=$_SHARED_OPENSSL_INCLUDES \
		--shared-openssl-libpath=$_SHARED_OPENSSL_LIBPATH \
		--shared-zlib \
		--with-intl=system-icu \
		--cross-compiling

	export LD_LIBRARY_PATH=$TERMUX_PKG_HOSTBUILD_DIR/icu-installed/lib
	perl -p -i -e "s@LIBS := \\$\\(LIBS\\)@LIBS := -L$TERMUX_PKG_HOSTBUILD_DIR/icu-installed/lib -lpthread -licui18n -licuuc -licudata -ldl -lz@" \
		$TERMUX_PKG_SRCDIR/out/tools/v8_gypfiles/mksnapshot.host.mk \
		$TERMUX_PKG_SRCDIR/out/tools/v8_gypfiles/torque.host.mk \
		$TERMUX_PKG_SRCDIR/out/tools/v8_gypfiles/bytecode_builtins_list_generator.host.mk \
		$TERMUX_PKG_SRCDIR/out/tools/v8_gypfiles/v8_libbase.host.mk \
		$TERMUX_PKG_SRCDIR/out/tools/v8_gypfiles/gen-regexp-special-case.host.mk
}
