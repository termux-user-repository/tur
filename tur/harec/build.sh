TERMUX_PKG_HOMEPAGE=https://harelang.org/
TERMUX_PKG_DESCRIPTION="The Hare programming language - bootstrap compiler"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=57a34f36c869b38e8cddade9174d1eb04a5f23c0
_COMMIT_DATE=2023.04.21
TERMUX_PKG_VERSION=${_COMMIT_DATE//./}
TERMUX_PKG_SRCURL=https://git.sr.ht/~sircmpwn/harec/archive/$_COMMIT.tar.gz
TERMUX_PKG_SHA256=7010f0f907e9c860c8fe6dcaf784de8eebc7ab932ceb5a105fa9cd05532e4703
TERMUX_PKG_BUILD_DEPENDS="binutils-cross, qbe-cross"
TERMUX_PKG_BLACKLISTED_ARCHES="i686, arm"
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_BUILD_IN_SRC=true
_CROSS_PREFIX="$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/cross"
TERMUX_PKG_EXTRA_MAKE_ARGS="HOST_HAREC=$_CROSS_PREFIX/bin/harec"

termux_step_host_build() {
	. "$TERMUX_PREFIX/opt/qbe/cross/setup.sh"

	"$TERMUX_PKG_SRCDIR/configure" --prefix="$_CROSS_PREFIX"
	make -j $TERMUX_PKG_MAKE_PROCESSES
	make install
	cp "$TERMUX_PKG_BUILDER_DIR/cross_setup.sh" "$_CROSS_PREFIX/setup.sh"
}

termux_step_configure() {
	# Remove this marker all the time.
	rm -rf $TERMUX_HOSTBUILD_MARKER

	if [ "$TERMUX_ON_DEVICE_BUILD" = false ]; then
		as="$TERMUX_PREFIX/opt/binutils/cross/$TERMUX_HOST_PLATFORM/bin/as"
	else
		as=as
	fi

	AS=$as "./configure" --prefix="$TERMUX_PREFIX" --target="$TERMUX_ARCH"
}
