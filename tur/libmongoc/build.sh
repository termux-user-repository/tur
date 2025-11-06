TERMUX_PKG_HOMEPAGE=https://github.com/mongodb/mongo-c-driver
TERMUX_PKG_DESCRIPTION="A high-performance MongoDB driver for C"
TERMUX_PKG_LICENSE="Apache-2.0, custom"
TERMUX_PKG_LICENSE_FILE="COPYING, THIRD_PARTY_NOTICES, src/libmongoc/THIRD_PARTY_NOTICES"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.30.3
TERMUX_PKG_SRCURL=https://github.com/mongodb/mongo-c-driver/releases/download/$TERMUX_PKG_VERSION/mongo-c-driver-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=9f42eb507e8c591546dc9c584230a6f71127842cb597cc4ab219d1ebe251e7af
TERMUX_PKG_DEPENDS="libbson, libicu, libmongocrypt, libsasl, libsnappy, openssl, zlib, zstd"
TERMUX_PKG_BUILD_DEPENDS="libbson-static, libmongocrypt-static"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX
-DCMAKE_INSTALL_LIBDIR=lib
-DUSE_SYSTEM_LIBBSON=ON
-DENABLE_TESTS=OFF
"

termux_step_pre_configure() {
	echo "!<arch>" > $TERMUX_PREFIX/lib/libresolv.a
}

termux_step_post_make_install() {
	rm $TERMUX_PREFIX/lib/libresolv.a
}
