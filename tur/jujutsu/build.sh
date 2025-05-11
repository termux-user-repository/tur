TERMUX_PKG_HOMEPAGE=https://jj-vcs.github.io/jj/
TERMUX_PKG_DESCRIPTION="A Git-compatible VCS that is both simple and powerful"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.29.0"
TERMUX_PKG_GIT_BRANCH="v$TERMUX_PKG_VERSION"
TERMUX_PKG_SRCURL=git+https://github.com/jj-vcs/jj
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="liblz4, xz-utils, openssl"
TERMUX_PKG_SUGGESTS="openssl"

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	RUSTFLAGS="-C strip=symbols -C codegen-units=1" BIOME_VERSION=$TERMUX_PKG_VERSION cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/jj
}
