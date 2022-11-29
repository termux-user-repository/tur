TERMUX_PKG_HOMEPAGE=https://github.com/asciinema/agg
TERMUX_PKG_DESCRIPTION="asciinema gif generator"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.3.0"
TERMUX_PKG_SRCURL="https://github.com/asciinema/agg/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=51cb553f9adde28f85e5e945c0013679c545820c4c023fefb9e74b765549e709
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true


termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_MAKE_PROCESSES --release
}

termux_step_make_install() {
	mv $TERMUX_PKG_SRCDIR/target/release/agg "${TERMUX_PREFIX}/bin/agg"
}
