TERMUX_PKG_HOMEPAGE=https://apps.gnome.org/Converter/
TERMUX_PKG_DESCRIPTION="Convert and manipulate images easily (GTK4/libadwaita frontend to ImageMagick)"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.6.0"
TERMUX_PKG_SRCURL="https://gitlab.com/adhami3310/Switcheroo/-/archive/v${TERMUX_PKG_VERSION}/Switcheroo-v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="237a7f37df7143961abdf47cdbe8586bcaa0ca8e885073617a2e20488256dbd1"

TERMUX_PKG_DEPENDS="gtk4, gdk-pixbuf, ghostscript, hicolor-icon-theme, libadwaita, imagemagick, glib, libheif, libiconv, libjpeg-turbo, libjxl, librsvg, libtiff, libwebp"
TERMUX_PKG_BUILD_DEPENDS="desktop-file-utils, glib-cross"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Dprofile=default
"

termux_step_pre_configure() {
	termux_setup_rust
	termux_setup_bpc
	termux_setup_glib_cross_pkg_config_wrapper

	export CARGO_BUILD_TARGET="${CARGO_TARGET_NAME}"

	local env_host=$(printf "$CARGO_TARGET_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
	export CARGO_TARGET_${env_host}_LINKER="$CC"

	export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=-liconv"

	export PKG_CONFIG
	export PKG_CONFIG_PATH="${TERMUX_PREFIX}/lib/pkgconfig"
	export PKG_CONFIG_LIBDIR="${TERMUX_PREFIX}/lib/pkgconfig"
	export PKG_CONFIG_SYSROOT_DIR="${TERMUX_PREFIX}"
	export PKG_CONFIG_ALLOW_CROSS=1

	export CFLAGS="${CFLAGS} -Wno-error=incompatible-function-pointer-types"
}

termux_step_post_configure() {
	mkdir -p "$TERMUX_PKG_BUILDDIR/src/release"
	ln -sf "$TERMUX_PKG_BUILDDIR/src/$CARGO_TARGET_NAME/release/switcheroo" \
		"$TERMUX_PKG_BUILDDIR/src/release/switcheroo"
}
