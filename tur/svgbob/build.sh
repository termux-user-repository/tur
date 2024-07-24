TERMUX_PKG_HOMEPAGE=https://github.com/ivanceras/svgbob
TERMUX_PKG_DESCRIPTION="Convert your ascii diagram scribbles into happy little SVG."
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.5.5"
TERMUX_PKG_SRCURL="https://github.com/ivanceras/svgbob/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=e17859725c7f59b21a351f31664a7fd50e04b336a7438421775c44d852589470
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_rust
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --release --target $CARGO_TARGET_NAME
}

termux_step_make_install() {
	install -Dm700 $TERMUX_PKG_SRCDIR/target/${CARGO_TARGET_NAME}/release/svgbob "${TERMUX_PREFIX}/bin/svgbob"
}

