TERMUX_PKG_HOMEPAGE=https://uutils.github.io/
TERMUX_PKG_DESCRIPTION="Cross-platform Rust rewrite of the GNU coreutils"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.2.2"
TERMUX_PKG_SRCURL=https://github.com/uutils/coreutils/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=4a847a3aaf241d11f07fdc04ef36d73c722759675858665bc17e94f56c4fbfb3
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_make() {
	termux_setup_rust

	# note: ld.lld: error: undefined reference due to --no-allow-shlib-undefined: syncfs
	local env_host=$(printf $CARGO_TARGET_NAME | tr a-z A-Z | sed s/-/_/g)
	export RUST_LIBDIR=$TERMUX_PKG_BUILDDIR/_lib
	mkdir -p "$RUST_LIBDIR"
	export CARGO_TARGET_${env_host}_RUSTFLAGS="-L${RUST_LIBDIR}"
	"${CC}" ${CPPFLAGS} -c "${TERMUX_PKG_BUILDER_DIR}/syncfs.c"
	"${AR}" rcu "${RUST_LIBDIR}/libsyncfs.a" syncfs.o
	export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=-l:libsyncfs.a"

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
