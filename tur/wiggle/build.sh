TERMUX_PKG_HOMEPAGE=https://github.com/neilbrown/wiggle
TERMUX_PKG_DESCRIPTION="A program for applying patches that patch cannot apply because of conflicting changes"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="1.3"
TERMUX_PKG_SRCURL="https://github.com/neilbrown/wiggle/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_DEPENDS="ncurses"
TERMUX_PKG_SHA256="ff92cf0133c1f4dce33563e263cb30e7ddb6f4abdf86d427b1ec1490bec25afa"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_MAKE_ARGS="wiggle"

termux_step_post_make_install() {
	install -Dm644 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME" notes
}
