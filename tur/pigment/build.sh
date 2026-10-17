TERMUX_PKG_HOMEPAGE=https://github.com/I-XXII-V/pigment
TERMUX_PKG_DESCRIPTION="Curated terminal color palettes for Termux, with live preview"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_LICENSE_FILES="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SRCURL="https://github.com/I-XXII-V/pigment/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="7df21ec67fbfc764d4f8c6c38d2622fdba3a30906ea234320a7533eca538b41d"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	install -Dm755 -t "$TERMUX_PREFIX/bin" "$TERMUX_PKG_SRCDIR/bin/pigment"
	install -d "$TERMUX_PREFIX/share/pigment/themes"
	install -Dm644 -t "$TERMUX_PREFIX/share/pigment/themes" "$TERMUX_PKG_SRCDIR"/themes/*.properties
	install -Dm644 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME" \
		"$TERMUX_PKG_SRCDIR/README.md" "$TERMUX_PKG_SRCDIR/ATTRIBUTION" "$TERMUX_PKG_SRCDIR/LICENSE"
}
