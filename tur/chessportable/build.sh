TERMUX_PKG_HOMEPAGE=https://github.com/GenzPx/chessportable
TERMUX_PKG_DESCRIPTION="Pure-Python terminal chess game with 20 bots, adaptive opponents, puzzles, and PGN export"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@GenzPx"
TERMUX_PKG_VERSION="3.0.0"
TERMUX_PKG_SRCURL=https://github.com/GenzPx/chessportable/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=18961ed58b2ac2887782cc9b11556638decbc057217c0c1b88439f7843dd2a11
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="python"
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make_install() {
	rm -rf "${TERMUX_PREFIX}/lib/chessportable"
	mkdir -p "${TERMUX_PREFIX}/lib/chessportable" "${TERMUX_PREFIX}/bin"
	cp -R "${TERMUX_PKG_SRCDIR}/chessportable" "${TERMUX_PREFIX}/lib/chessportable/chessportable"

	cat > "${TERMUX_PREFIX}/bin/chessportable" <<-EOF
		#!${TERMUX_PREFIX}/bin/sh
		export PYTHONPATH="${TERMUX_PREFIX}/lib/chessportable\${PYTHONPATH:+:\$PYTHONPATH}"
		exec python3 -m chessportable "\$@"
	EOF
	chmod 0755 "${TERMUX_PREFIX}/bin/chessportable"
}
