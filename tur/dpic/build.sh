TERMUX_PKG_HOMEPAGE="https://ece.uwaterloo.ca/~aplevich/dpic/"
TERMUX_PKG_DESCRIPTION="Implementation of the pic little language for creating line drawings and illustrations"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="Copyright.txt"
TERMUX_PKG_MAINTAINER="Gouranga Das Samrat <gouranga.das.khulna@gmail.com>"
TERMUX_PKG_VERSION="2025.08.01"
TERMUX_PKG_SRCURL="https://ece.uwaterloo.ca/~aplevich/dpic/dpic-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="0f38f5c1e91518826cb2c6e95624b390d1808efadc0402f83911512f0ce726c3"
TERMUX_PKG_AUTO_UPDATE=true

TERMUX_PKG_BUILD_IN_SRC=true

termux_step_configure() {
	:
}

termux_step_make() {
	make \
		CC="$CC" \
		CFLAGS="$CFLAGS" \
		CPPFLAGS="$CPPFLAGS" \
		LDFLAGS="$LDFLAGS -lm"
}

termux_step_make_install() {
	install -Dm755 dpic "$TERMUX_PREFIX/bin/dpic"
}
