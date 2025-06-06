TERMUX_PKG_HOMEPAGE=https://nodejs.org/
TERMUX_PKG_DESCRIPTION="Open Source, cross-platform JavaScript runtime environment (Version 12, EOL at Apr 05, 2022)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=12.18.3
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=https://nodejs.org/dist/v${TERMUX_PKG_VERSION}/node-v${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=71158026579487422fd13cc2553b34cddb76519098aa6030faab52f88c6e0d0e
# Note that we do not use a shared libuv to avoid an issue with the Android
# linker, which does not use symbols of linked shared libraries when resolving
# symbols on dlopen(). See https://github.com/termux/termux-packages/issues/462.
TERMUX_PKG_DEPENDS="libc++, openssl-1.1, c-ares, zlib"
TERMUX_PKG_SUGGESTS="clang, make, pkg-config, python"
_INSTALL_PREFIX=opt/nodejs-12
TERMUX_PKG_RM_AFTER_INSTALL="
$_INSTALL_PREFIX/lib/node_modules/npm/html
$_INSTALL_PREFIX/lib/node_modules/npm/make.bat
$_INSTALL_PREFIX/share/systemtap
$_INSTALL_PREFIX/lib/dtrace
"
TERMUX_PKG_BUILD_IN_SRC=true

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
	local _host_compiler_suffix=""
	if [ $TERMUX_ARCH_BITS = 32 ]; then
		_host_compiler_suffix="-m32"
	fi
	export CC_host="gcc $_host_compiler_suffix"
	export CXX_host="g++ $_host_compiler_suffix"
	export LINK_host="g++ $_host_compiler_suffix"

	LDFLAGS+=" -ldl"

	# For pipe2
	CFLAGS+=" -D__USE_GNU=1"
	CPPFLAGS+=" -D__USE_GNU=1"
	CXXFLAGS+=" -D__USE_GNU=1"

	local _SHARED_OPENSSL_INCLUDES=$TERMUX_PREFIX/include
	local _SHARED_OPENSSL_LIBPATH=$TERMUX_PREFIX/lib

	if [ "${TERMUX_PKG_VERSION%%.*}" -gt "16" ]; then
		termux_error_exit 'Please migrate to using openssl (instead of openssl-1.1).'
	else
		_SHARED_OPENSSL_INCLUDES=$TERMUX_PREFIX/include/openssl-1.1
		_SHARED_OPENSSL_LIBPATH=$TERMUX_PREFIX/lib/openssl-1.1
		LDFLAGS="-Wl,-rpath=$_SHARED_OPENSSL_LIBPATH $LDFLAGS"
	fi

	mkdir -p $TERMUX_PREFIX/$_INSTALL_PREFIX
	LDFLAGS="-Wl,-rpath=$TERMUX_PREFIX/$_INSTALL_PREFIX/lib $LDFLAGS"

	# See note above TERMUX_PKG_DEPENDS why we do not use a shared libuv.
	python configure.py \
		--prefix=$TERMUX_PREFIX/$_INSTALL_PREFIX \
		--dest-cpu=$DEST_CPU \
		--dest-os=android \
		--shared-cares \
		--shared-openssl \
		--shared-openssl-includes=$_SHARED_OPENSSL_INCLUDES \
		--shared-openssl-libpath=$_SHARED_OPENSSL_LIBPATH \
		--shared-zlib \
		--with-intl=full-icu --download=all \
		--without-snapshot \
		--without-node-snapshot \
		--cross-compiling

	sed -i "s@-I$TERMUX_PREFIX/include/openssl-1.1@ @
			s@-I$TERMUX_PREFIX/include@ @
			s@-L$TERMUX_PREFIX/lib/openssl-1.1@ @
			s@-L$TERMUX_PREFIX/lib@ @" \
		$TERMUX_PKG_SRCDIR/out/tools/icu/*.host.mk \
		$TERMUX_PKG_SRCDIR/out/tools/v8_gypfiles/*.host.mk
}
