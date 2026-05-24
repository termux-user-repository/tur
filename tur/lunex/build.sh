TERMUX_PKG_HOMEPAGE=https://github.com/Megamexlevi2/lunex-lang-gz
TERMUX_PKG_DESCRIPTION="Lunex programming language"
TERMUX_PKG_LICENSE="MPL-2.0"
TERMUX_PKG_MAINTAINER="David Dev"
TERMUX_PKG_VERSION=0.4.1

TERMUX_PKG_SRCURL=https://github.com/Megamexlevi2/lunex-lang-gz/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed

TERMUX_PKG_BUILD_DEPENDS="golang zig"

TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
    cd "$TERMUX_PKG_SRCDIR"
    chmod +x build-termux.sh
    ./build-termux.sh build
}

termux_step_make_install() {
    install -Dm755 lunex "$TERMUX_PREFIX/bin/lunex"
}