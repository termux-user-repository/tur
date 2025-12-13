TERMUX_PKG_HOMEPAGE="https://gwc.sourceforge.net/"
TERMUX_PKG_DESCRIPTION="GTK2 application for cleaning noise in digital music recordings (e.g. digitized vinyl recordings)"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="0.22-06r3"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL="https://github.com/AlisterH/gwc/releases/download/${TERMUX_PKG_VERSION%r*}/gtk-wave-cleaner-${TERMUX_PKG_VERSION%r*}.tar.gz"
TERMUX_PKG_SHA256=0c5e58c195ac2aff5822703796a136d1cff5fffd1e5d787eddbae98ebf179854
TERMUX_PKG_DEPENDS="fftw, libsndfile, gtk2, alsa-lib"
TERMUX_PKG_BUILD_DEPENDS="aosp-libs"
TERMUX_PKG_SUGGESTS="alsa-plugins"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_MAKE_PROCESSES=1

termux_step_pre_configure() {
	autoreconf -fi

	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		termux_setup_proot
		patch="$TERMUX_PKG_BUILDER_DIR/termux-proot-run.diff"
		echo "Applying patch: $(basename "$patch")"
		patch --silent -p1 < "$patch"
	fi
}
