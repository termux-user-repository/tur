TERMUX_PKG_HOMEPAGE=https://github.com/mertcakh2-cmd/Oh-my-perA
TERMUX_PKG_DESCRIPTION="Personal Termux theme and configuration"
TERMUX_PKG_LICENSE=MIT
TERMUX_PKG_MAINTAINER="mertcakh2-cmd"
TERMUX_PKG_VERSION=1.0.0
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
install -Dm644 "$TERMUX_PKG_SRCDIR/.termux/colors.properties" 
"$TERMUX_PREFIX/share/oh-my-pera/colors.properties"

install -Dm644 "$TERMUX_PKG_SRCDIR/.termux/termux.properties" \
    "$TERMUX_PREFIX/share/oh-my-pera/termux.properties"

install -Dm755 "$TERMUX_PKG_SRCDIR/.termux/boot/startup.sh" \
    "$TERMUX_PREFIX/share/oh-my-pera/startup.sh"

}
