TERMUX_PKG_HOMEPAGE=https://github.com/mongodb/libmongocrypt
TERMUX_PKG_DESCRIPTION="The companion C library for MongoDB client side encryption in drivers"
TERMUX_PKG_LICENSE="Apache-2.0, custom"
TERMUX_PKG_LICENSE_FILE="LICENSE, kms-message/THIRD_PARTY_NOTICES"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1:1.13.2
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/mongodb/libmongocrypt/archive/refs/tags/${TERMUX_PKG_VERSION#*:}.tar.gz
TERMUX_PKG_SHA256=af15439e3f3e25ded3d4d0d4dac0b84984ed394a8d68c69343445ed8f9f46df5
TERMUX_PKG_DEPENDS="libbson, libicu, libsasl, libsnappy, openssl"
TERMUX_PKG_CONFLICTS="libmongoc (<< 1.30.3)"
TERMUX_PKG_BREAKS="libmongoc (<< 1.30.3)"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX
-DCMAKE_INSTALL_LIBDIR=lib
-DBUILD_VERSION=${TERMUX_PKG_VERSION#*:}
-DUSE_SHARED_LIBBSON=ON
-DMONGOCRYPT_MONGOC_DIR=USE-SYSTEM
-DENABLE_ONLINE_TESTS=OFF
-DMONGOCRYPT_ENABLE_DECIMAL128=OFF
"

termux_step_pre_configure() {
	echo "!<arch>" > $TERMUX_PREFIX/lib/libresolv.a
}

termux_step_post_make_install() {
	rm $TERMUX_PREFIX/lib/libresolv.a
}
