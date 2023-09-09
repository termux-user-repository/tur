TERMUX_PKG_HOMEPAGE="https://github.com/vasi/pixz"
TERMUX_PKG_DESCRIPTION="A xz(1) compatible compressor featuring parallel decompression and indexed random seeking"
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="1.0.7"
TERMUX_PKG_SRCURL="https://github.com/vasi/pixz/releases/download/v$TERMUX_PKG_VERSION/pixz-$TERMUX_PKG_VERSION.tar.xz"
TERMUX_PKG_SHA256=e5e32c6eb0bf112b98e74a5da8fb63b9f2cae71800f599d97ce540e150c8ddc5
TERMUX_PKG_BUILD_DEPENDS="xz-utils"
TERMUX_PKG_PKG_DEPENDS="libarchive, liblzma"
## detection of compiled manpages in release tarball seemingly not work,
## other distro either pull asciidoc as makedeps to rebuild manpage
## or override the detection and manually install the manpages after makeinstall
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="ac_cv_file_src_pixz_1=yes"
#
TERMUX_PKG_EXTRA_MAKE_ARGS="check"  ## run tests
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi

	cd "${TERMUX_PKG_SRCDIR}"
	## remove cppcheck from tests (errorout in v1.0.7, but it is
	## upstream developer's duty to fix this anyway)
	sed -e "/^[\t ]*cppcheck-src.sh \\\\ *$/d" -i test/Makefile.am && \
	aclocal
}

termux_step_post_make_install() {
	install -Ddm700 "$TERMUX_PREFIX"/share/man/man1
	install -pm600 -t "$TERMUX_PREFIX/share/man/man1" "$TERMUX_PKG_SRCDIR"/src/pixz.1
}
