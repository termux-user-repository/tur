TERMUX_PKG_HOMEPAGE=https://uutils.github.io/
TERMUX_PKG_DESCRIPTION="Cross-platform Rust rewrite of the GNU coreutils"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.1.0"
TERMUX_PKG_SRCURL=https://github.com/uutils/coreutils/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=55c528f2b53c1b30cb704550131a806e84721c87b3707b588a961a6c97f110d8
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_make() {
	termux_setup_rust

	_renv="CXXFLAGS_${CARGO_TARGET_NAME//-/_}"
	export $_renv="$CXXFLAGS"
	unset CXXFLAGS

	make \
		PROFILE=release \
		MULTICALL=y \
		CARGOFLAGS="--target $CARGO_TARGET_NAME" \
		SELINUX_ENABLED=0 \
		MANPAGES=0 \
		COMPLETIONS=0 \
		SKIP_UTILS="pinky uptime users who hostid chcon runcon"
}

termux_step_make_install() {
	make install \
		DESTDIR=/ \
		PREFIX="$TERMUX_PREFIX" \
		PROG_PREFIX=uu- \
		PROFILE=release \
		MULTICALL=y \
		CARGOFLAGS="--target $CARGO_TARGET_NAME" \
		CARGO_TARGET_DIR="$(pwd)/target/$CARGO_TARGET_NAME" \
		SELINUX_ENABLED=0 \
		MANPAGES=0 \
		COMPLETIONS=0 \
		SKIP_UTILS="pinky uptime users who hostid chcon runcon"
}
