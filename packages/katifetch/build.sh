TERMUX_PKG_HOMEPAGE=https://github.com/ximimoments/katifetch
TERMUX_PKG_DESCRIPTION="A cross-platform system information tool written in Bash"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="ximimoments <valentinomartinezferreira456@gmail.com>"
TERMUX_PKG_VERSION=13.1
TERMUX_PKG_SRCURL=https://github.com/ximimoments/katifetch/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=57018797a61ab6befb80a0b76cdf7ca457421ef8cfc030fe41d77a78b017fd30
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
    install -Dm755 "$TERMUX_PKG_SRCDIR/katifetch.sh" "$TERMUX_PREFIX/bin/katifetch"
}
