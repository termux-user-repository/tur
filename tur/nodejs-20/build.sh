TERMUX_PKG_HOMEPAGE=https://nodejs.org/
TERMUX_PKG_DESCRIPTION="Open Source, cross-platform JavaScript runtime environment"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=20.14.0
TERMUX_PKG_SRCURL=https://nodejs.org/dist/v${TERMUX_PKG_VERSION}/node-v${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=08655028f0d8436e88163f9186044d635d3f36a85ee528f36bd05b6c5e46c1bb
# Note that we do not use a shared libuv to avoid an issue with the Android
# linker, which does not use symbols of linked shared libraries when resolving
# symbols on dlopen(). See https://github.com/termux/termux-packages/issues/462.
TERMUX_PKG_DEPENDS="libc++, openssl, c-ares, zlib"
TERMUX_PKG_CONFLICTS="nodejs, nodejs-current"
_INSTALL_PREFIX=opt/nodejs-20
TERMUX_PKG_RM_AFTER_INSTALL="
$_INSTALL_PREFIX/lib/node_modules/npm/html
$_INSTALL_PREFIX/lib/node_modules/npm/make.bat
$_INSTALL_PREFIX/share/systemtap
$_INSTALL_PREFIX/lib/dtrace
"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_ninja
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
	local _host_compiler_suffix=""
	if [ $TERMUX_ARCH_BITS = 32 ]; then
		_host_compiler_suffix="-m32"
	fi
	export CC_host="gcc $_host_compiler_suffix"
	export CXX_host="g++ $_host_compiler_suffix"
	export LINK_host="g++ $_host_compiler_suffix"

	mkdir -p $TERMUX_PREFIX/$_INSTALL_PREFIX
	LDFLAGS="-Wl,-rpath=$TERMUX_PREFIX/$_INSTALL_PREFIX/lib $LDFLAGS"

	# See note above TERMUX_PKG_DEPENDS why we do not use a shared libuv
	# When building with ninja, build.ninja is geenrated for both Debug and Release builds.
	./configure \
		--prefix=$TERMUX_PREFIX/$_INSTALL_PREFIX \
		--dest-cpu=$DEST_CPU \
		--dest-os=android \
		--shared-cares \
		--shared-openssl \
		--shared-zlib \
		--with-intl=full-icu \
		--cross-compiling \
		--ninja

	sed -i \
		-e "s|\-I$TERMUX_PREFIX/include| |g" \
		-e "s|\-L$TERMUX_PREFIX/lib| |g" \
		$(find $TERMUX_PKG_SRCDIR/out/{Release,Debug}/obj.host -name '*.ninja')
}

termux_step_make() {
	if [ "${TERMUX_DEBUG_BUILD}" = "true" ]; then
		ninja -C out/Debug -j "${TERMUX_PKG_MAKE_PROCESSES}"
	else
		ninja -C out/Release -j "${TERMUX_PKG_MAKE_PROCESSES}"
	fi
}

termux_step_make_install() {
	if [ "${TERMUX_DEBUG_BUILD}" = "true" ]; then
		python tools/install.py install --dest-dir="" --prefix "$TERMUX_PREFIX/$_INSTALL_PREFIX" --build-dir out/Debug/
	else
		python tools/install.py install --dest-dir="" --prefix "$TERMUX_PREFIX/$_INSTALL_PREFIX" --build-dir out/Release/
	fi
}
