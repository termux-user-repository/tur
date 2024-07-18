TERMUX_PKG_HOMEPAGE=https://github.com/JayXon/Leanify.git
TERMUX_PKG_DESCRIPTION="Lightweight lossless file minifier/optimize"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Joshua Kahn @TomJo2000"
TERMUX_PKG_VERSION=0.4.3+20231217
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_SRCURL=git+https://github.com/JayXon/Leanify.git
TERMUX_PKG_DEPENDS='libiconv'
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_configure() {
	LDFLAGS+=' -liconv'
	CFLAGS+=' -Wno-error=unused-but-set-variable'
	case "$TERMUX_ARCH" in
		'arm'|'i686') CFLAGS+=' -Wno-error=format';;
	esac
}

# Makefile includes no install target
termux_step_make_install() {
	install -Dm755 -t "$TERMUX_PREFIX/bin" "${TERMUX_PKG_SRCDIR}/leanify"
}
