TERMUX_PKG_HOMEPAGE=http://data.astrometry.net/
TERMUX_PKG_DESCRIPTION="astrometry.net index data file 4115-4119, suitable for astro photos taken by phone main camera (AOV ~ 70 degrees)"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="copyright"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1"
TERMUX_PKG_SKIP_SRC_EXTRACT=true

termux_step_post_get_source () {
	cp "$TERMUX_PKG_BUILDER_DIR"/copyright "$TERMUX_PKG_SRCDIR"/
}

termux_step_make_install () {
	mkdir -p "$TERMUX_PREFIX/data/"
	termux_download http://data.astrometry.net/4100/index-4115.fits "$TERMUX_PREFIX/data/" 548f6c438b5062519e27e83bc7cdc1743705068e327fabe4cc039a4319542953
	termux_download http://data.astrometry.net/4100/index-4116.fits "$TERMUX_PREFIX/data/" de811b8513cb2499ace8ce26a79ed8082e5ec19972f2a5d967e5c3b93c475b5a
	termux_download http://data.astrometry.net/4100/index-4117.fits "$TERMUX_PREFIX/data/" 7de4d4f8827d5622ff1ed5252ab8b18d6b576b48f63a8927b5887bc8fa418f45
	termux_download http://data.astrometry.net/4100/index-4118.fits "$TERMUX_PREFIX/data/" 5e79c1812ac6fdf11a360b04e82079b87e318ed36a618c21de23441195e67d0f
	termux_download http://data.astrometry.net/4100/index-4119.fits "$TERMUX_PREFIX/data/" 79b36eea45b72448c8471f6e8af0e1c8635a3821d04f1a23d6cf5ecd5f59d31c
}
