TERMUX_PKG_HOMEPAGE=https://github.com/JuliaMath/openspecfun
TERMUX_PKG_DESCRIPTION="A collection of special mathematical functions"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.5.6
TERMUX_PKG_SRCURL=https://github.com/JuliaMath/openspecfun/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=f77401cdadde8e4c59cd862ebb71a015141f7ad3dca638a17dd617b5e801572a
TERMUX_PKG_BUILD_IN_SRC=true

source $TERMUX_SCRIPTDIR/common-files/setup_toolchain_gcc.sh

termux_step_pre_configure() {
	_setup_toolchain_ndk_gcc_11
}

termux_step_make() {
	make -j $TERMUX_MAKE_PROCESSES prefix="$PREFIX" \
			FFLAGS="$FCFLAGS" CFLAGS="$CFLAGS" CPPFLAGS="$CPPFLAGS" \
			FC="$FC" CC="$CC" AR="$AR"
}

termux_step_make_install() {
	 make install -j 1 prefix="$PREFIX" \
			FFLAGS="$FCFLAGS" CFLAGS="$CFLAGS" CPPFLAGS="$CPPFLAGS" \
			FC="$FC" CC="$CC" AR="$AR"
}
