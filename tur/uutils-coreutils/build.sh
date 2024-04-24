TERMUX_PKG_HOMEPAGE=https://uutils.github.io/
TERMUX_PKG_DESCRIPTION="Cross-platform Rust rewrite of the GNU coreutils"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.0.25"
TERMUX_PKG_SRCURL=https://github.com/uutils/coreutils/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=e6e4626e18eb5bd68480fc4860dc6203259a931d0357f8da900d8f5d6926c7ce
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_make() {
	termux_setup_rust

	_renv="CXXFLAGS_${CARGO_TARGET_NAME//-/_}"
	export $_renv="$CXXFLAGS"
	unset CXXFLAGS

	make PROFILE=release \
		CARGO_TARGET_NAME="$CARGO_TARGET_NAME" \
		SELINUX_ENABLED=0 \
		SKIP_UTILS="pinky uptime users who hostid"
}

termux_step_make_install() {
	make install \
		DESTDIR=/ \
		PREFIX="$TERMUX_PREFIX" \
		PROG_PREFIX=uu- \
		PROFILE=release \
		MULTICALL=y \
		CARGO_TARGET_NAME="$CARGO_TARGET_NAME" \
		SELINUX_ENABLED=0 \
		SKIP_UTILS="pinky uptime users who hostid"
}
