TERMUX_PKG_HOMEPAGE=https://github.com/iovisor/bcc
TERMUX_PKG_DESCRIPTION="Tools for BPF-based Linux IO analysis, networking, monitoring, and more"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.27.0
TERMUX_PKG_SRCURL=https://github.com/iovisor/bcc/releases/download/v$TERMUX_PKG_VERSION/bcc-src-with-submodule.tar.gz
TERMUX_PKG_SHA256=157208df3c8c0473b5dbedd57648fb98b5d07e5565984affc4e3e84a3df601bc
TERMUX_PKG_DEPENDS="clang, libc++, libdebuginfod, libelf, liblzma, ncurses, zlib, zstd"
TERMUX_PKG_BUILD_DEPENDS="libllvm-static"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DREVISION=$TERMUX_PKG_VERSION
-DPYTHON_CMD=python$TERMUX_PYTHON_VERSION
-DENABLE_TESTS=OFF
-DRUN_LUA_TESTS=OFF
-DBCC_PROG_TAG_DIR=$TERMUX_PREFIX/var/tmp/bcc
"

termux_step_post_make_install() {
	termux_setup_python_pip

	pushd $TERMUX_PKG_BUILDDIR/src/python/bcc-python$TERMUX_PYTHON_VERSION
	pip install --prefix=$TERMUX_PREFIX .
	popd

	rm -rf $TERMUX_PREFIX/lib/python3/
}
