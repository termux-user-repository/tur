TERMUX_PKG_HOMEPAGE=https://uutils.github.io/
TERMUX_PKG_DESCRIPTION="Cross-platform Rust rewrite of the GNU coreutils"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.0.29"
TERMUX_PKG_SRCURL=https://github.com/uutils/coreutils/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=e1904ed6e5b8b441bedcba5afa7e8e8c744ef701f6d392de8c8dcc2ea17a34e2
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
