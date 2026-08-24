TERMUX_PKG_HOMEPAGE=https://github.com/alexfru/SmallerC
TERMUX_PKG_DESCRIPTION="Simple and small C compiler for DOS, Windows, Linux and MacOS"
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.0.2
TERMUX_PKG_REVISION=4
TERMUX_PKG_SRCURL="https://github.com/alexfru/SmallerC/archive/refs/tags/v${TERMUX_PKG_VERSION}+dos.win.b120a9c.tar.gz"
TERMUX_PKG_SHA256=1e26ed8da461614da26379b7be1510f0e39f52a292fd0d9e54d747664f0c7ef4
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="nasm"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_EXTRA_MAKE_ARGS="prefix=$TERMUX_PREFIX"

termux_step_host_build() {
	# smallerc-cross subpackage cannot be built on-device
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "true" ]]; then
		return
	fi

	local _PREFIX_FOR_BUILD="${TERMUX_PREFIX}/opt/$TERMUX_PKG_NAME/cross"
	cd "$TERMUX_PKG_SRCDIR"
	make prefix="$_PREFIX_FOR_BUILD"
	make install prefix="$_PREFIX_FOR_BUILD"
	make clean
}

termux_step_pre_configure() {
	# ensures rebuilding the package always rebuilds smallerc-cross
	rm -f "$TERMUX_HOSTBUILD_MARKER"

	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		local _PREFIX_FOR_BUILD="${TERMUX_PREFIX}/opt/$TERMUX_PKG_NAME/cross"
		export PATH="$PATH:$_PREFIX_FOR_BUILD/bin"
		export SMLRCC="${_PREFIX_FOR_BUILD}/bin/smlrcc"
	fi
}
