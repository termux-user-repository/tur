TERMUX_PKG_HOMEPAGE=https://github.com/mongodb/mongo-c-driver
TERMUX_PKG_DESCRIPTION="A high-performance MongoDB driver for C"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.22.2
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=https://github.com/mongodb/mongo-c-driver/releases/download/$TERMUX_PKG_VERSION/mongo-c-driver-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=2e59b9d38d600bd63ccc0b215dd44c6254a66eeb8085a5ac513748cd6220532e
TERMUX_PKG_DEPENDS="libicu, libsasl, libmongocrypt, openssl, zlib, zstd"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DENABLE_TESTS=OFF"

termux_step_pre_configure() {
	echo "!<arch>" > $TERMUX_PREFIX/lib/libresolv.a
}

termux_step_post_make_install() {
	rm $TERMUX_PREFIX/lib/libresolv.a
}
