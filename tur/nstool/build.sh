TERMUX_PKG_HOMEPAGE="https://github.com/jakcron/nstool"
TERMUX_PKG_DESCRIPTION="General purpose read/extract tool for Switch dumps"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_SRCURL="git+https://github.com/jakcron/nstool"
TERMUX_PKG_VERSION="1.9.2"
TERMUX_PKG_GIT_BRANCH=stable
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	#git fetch --unshallow --no-recurse-submodules
	git checkout "v$TERMUX_PKG_VERSION"
	git submodule update --init --recursive --depth=1
}

termux_step_make() {
	export CC="$CC $CFLAGS $CPPFLAGS $LDFLAGS"
	export CXX="$CXX $CXXFLAGS $CPPFLAGS $LDFLAGS"
	make -j $TERMUX_PKG_MAKE_PROCESSES deps
	make -j $TERMUX_PKG_MAKE_PROCESSES
}

termux_step_make_install() {
	install -Dm755 -t "$TERMUX_PREFIX/bin" ./bin/nstool
	install -Dm644 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME" README.md SWITCH_KEYS.md
}
