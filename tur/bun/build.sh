TERMUX_PKG_HOMEPAGE=https://bun.com
TERMUX_PKG_DESCRIPTION="Incredibly fast JavaScript runtime, bundler, test runner, and package manager"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="1.4.0"
TERMUX_PKG_SRCURL=(
	https://github.com/oven-sh/bun/releases/download/bun-v$TERMUX_PKG_VERSION/bun-linux-aarch64-android.zip
	https://github.com/oven-sh/bun/releases/download/bun-v$TERMUX_PKG_VERSION/bun-linux-x64-android.zip
)
TERMUX_PKG_SHA256=(
	42544d7438bb92c7e7df7d30b9a5858cb7a834636608e5b850f59138283567fc
	3425dbabc87aad92eb37d384d561edd4d676ee2b328c02d77d761504aeef6764
)
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXCLUDED_ARCHES="arm,i686"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	curl -fsSL "https://raw.githubusercontent.com/oven-sh/bun/main/LICENSE.md" \
		-o "$TERMUX_PKG_SRCDIR/LICENSE"
}

termux_step_make() {
	: # prebuilt binary, nothing to build
}

termux_step_make_install() {
	local _BUN_ARCH
	case "$TERMUX_ARCH" in
		aarch64) _BUN_ARCH=aarch64 ;;
		x86_64)  _BUN_ARCH=x64 ;;
	esac

	# Whether the zip's top-level folder gets auto-stripped or not
	# depends on extraction order/behavior, so check both possible
	# locations instead of assuming one.
	local _bun_bin
	if [ -f "$TERMUX_PKG_SRCDIR/bun-linux-${_BUN_ARCH}-android/bun" ]; then
		_bun_bin="$TERMUX_PKG_SRCDIR/bun-linux-${_BUN_ARCH}-android/bun"
	elif [ -f "$TERMUX_PKG_SRCDIR/bun" ]; then
		_bun_bin="$TERMUX_PKG_SRCDIR/bun"
	else
		termux_error_exit "Could not locate bun binary for $TERMUX_ARCH in $TERMUX_PKG_SRCDIR"
	fi

	install -Dm755 "$_bun_bin" "$TERMUX_PREFIX/bin/bun"
}
