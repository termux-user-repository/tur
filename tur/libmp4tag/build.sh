TERMUX_PKG_HOMEPAGE="https://sourceforge.net/p/libmp4tag/"
TERMUX_PKG_DESCRIPTION="Library and CLI utility for tagging MP4 file"
TERMUX_PKG_LICENSE="ZLIB"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="2.0.1"
_COMMIT="474a6b478db8053368f71c6752c44e6278a61a31"
TERMUX_PKG_SRCURL="https://sourceforge.net/code-snapshots/hg/l/li/libmp4tag/code/libmp4tag-code-$_COMMIT.zip"
TERMUX_PKG_SHA256="SKIP_CHECKSUM"

termux_step_post_make_install() {
	install -Dm644 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME" "$TERMUX_PKG_SRCDIR"/README*
}
