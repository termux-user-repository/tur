TERMUX_PKG_HOMEPAGE=https://c9x.me/compile/
TERMUX_PKG_DESCRIPTION="Small embeddable C compiler backend"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.1
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://c9x.me/compile/release/qbe-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=7d0a53dd40df48072aae317e11ddde15d1a980673160e514e235b9ecaa1db12c
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BLACKLISTED_ARCHES="i686, arm"

# For qbe-cross:
TERMUX_PKG_HOSTBUILD=true
_CROSS_PREFIX="$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/cross"
TERMUX_PKG_EXTRA_HOSTBUILD_MAKE_ARGS="
PREFIX=$_CROSS_PREFIX
OUTDIR=$TERMUX_PKG_HOSTBUILD_DIR
"

termux_step_host_build() {
	cd $TERMUX_PKG_SRCDIR

	make $TERMUX_PKG_EXTRA_HOSTBUILD_MAKE_ARGS -j $TERMUX_PKG_MAKE_PROCESSES
	make install $TERMUX_PKG_EXTRA_HOSTBUILD_MAKE_ARGS
	cp "$TERMUX_PKG_BUILDER_DIR/cross_setup.sh" "$_CROSS_PREFIX/setup.sh"
}

termux_step_configure() {
	# Remove this marker all the time.
	rm -rf $TERMUX_HOSTBUILD_MARKER

	case "$TERMUX_ARCH" in
		aarch64)
			echo "#define Deftgt T_arm64"
			;;
		x86_64)
			echo "#define Deftgt T_amd64_sysv"
			;;
		riscv64)
			echo "#define Deftgt T_rv64"
			;;
		*)
			printf "Error: unsupported or unrecognized architecture %s\n" "$TERMUX_ARCH"
			exit 1
			;;
	esac > $TERMUX_PKG_SRCDIR/config.h
}
