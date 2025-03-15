TERMUX_PKG_HOMEPAGE=https://github.com/kholtman/afio
TERMUX_PKG_DESCRIPTION="A legacy archiving & backup utility that is capable to work with \"large ASCII\" cpio archive"
TERMUX_PKG_LICENSE="custom:afio"
TERMUX_PKG_LICENSE_FILE="afio_license_issues_v5.txt"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="2.5.2"
TERMUX_PKG_SHA256=c64ca14109df547e25702c9f3a9ca877881cd4bf38dcbe90fbd09c8d294f42b9
TERMUX_PKG_SRCURL="https://github.com/kholtman/afio/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	CFLAGS+=" -Wno-implicit-function-declaration"
	make CC="${CC:-cc}"
}

termux_step_make_install() {
	install -Dm755 -t "$TERMUX_PREFIX/bin" afio
	install -Dm644 -t "$TERMUX_PREFIX/share/man/man1" afio.1
	install -Dm644 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME" README* HISTORY SCRIPTS
	cp -r script{1,2,3,4} -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME"
}
