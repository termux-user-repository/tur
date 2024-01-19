TERMUX_PKG_HOMEPAGE=https://github.com/fcambus/ansiweather
TERMUX_PKG_DESCRIPTION="Weather in terminal, with ANSI colors and Unicode symbols"
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_LICENSE_FILES="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.19.0
TERMUX_PKG_SRCURL=https://github.com/fcambus/ansiweather/releases/download/$TERMUX_PKG_VERSION/ansiweather-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=5c902d4604d18d737c6a5d97d2d4a560717d72c8e9e853b384543c008dc46f4d
TERMUX_PKG_DEPENDS="bc, curl, jq"
TERMUX_PKG_ANTI_BUILD_DEPENDS="bc, curl, jq"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	install -Dm755 $TERMUX_PKG_SRCDIR/ansiweather $TERMUX_PREFIX/bin/ansiweather
	install -Dm644 $TERMUX_PKG_SRCDIR/ansiweather.1 $TERMUX_PREFIX/share/man/man1/ansiweather.1
}
