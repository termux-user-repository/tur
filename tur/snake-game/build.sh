TERMUX_PKG_HOMEPAGE="https://github.com/Renderfox743/snake-game"
TERMUX_PKG_DESCRIPTION="A classic Snake game for Termux terminal"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@Renderfox743"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL="https://github.com/Renderfox743/snake-game/archive/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="4e08457d06891d62b8e3936e19e5b37dbf77decfcace5b072b5f6ea21f23e239"
TERMUX_PKG_DEPENDS="bash"
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make_install() {
    install -Dm700 snake.sh $TERMUX_PREFIX/bin/snake-game
}
