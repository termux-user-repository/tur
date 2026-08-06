TERMUX_PKG_HOMEPAGE=https://github.com/inrryoff/susdu
TERMUX_PKG_DESCRIPTION="Uma alternativa moderna ao tsu para diferentes root managers"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@inrryoff"
TERMUX_PKG_VERSION=1.0.0
TERMUX_PKG_SRCURL=https://github.com/inrryoff/susdu/releases/download/v1.0.0/susdu-1.0.0.tar.gz
TERMUX_PKG_SHA256=29de68bcc67f26d546c3f60a2e2d10d55b6cb1b3c6583f7862310dcf5526871c
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	install -Dm755 "$TERMUX_PKG_SRCDIR/susdu" "$TERMUX_PREFIX/bin/susdu"
}
