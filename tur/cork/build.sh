TERMUX_PKG_HOMEPAGE="https://github.com/sapirrior/cork"
TERMUX_PKG_DESCRIPTION="Core Operations & Runtime Kernel - A minimal command runner"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="sapirrior"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SRCURL="https://github.com/sapirrior/cork/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="89c36b0714b8ba9f97672292fadd69c35a501e3e559c133c7cb50c4e00700c3c"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	$CC $CFLAGS $CPPFLAGS cork.c -o cork $LDFLAGS
}

termux_step_make_install() {
	install -Dm755 cork $TERMUX_PREFIX/bin/cork
}
