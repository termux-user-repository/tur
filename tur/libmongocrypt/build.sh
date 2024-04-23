TERMUX_PKG_HOMEPAGE=https://github.com/mongodb/libmongocrypt
TERMUX_PKG_DESCRIPTION="The companion C library for MongoDB client side encryption in drivers"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=(2.3.0)
TERMUX_PKG_VERSION+=(1.22.2)
TERMUX_PKG_REVISION=3
TERMUX_PKG_SRCURL=(https://github.com/mongodb/libmongocrypt/archive/refs/tags/node-v${TERMUX_PKG_VERSION[0]}.tar.gz)
TERMUX_PKG_SRCURL+=(https://github.com/mongodb/mongo-c-driver/releases/download/${TERMUX_PKG_VERSION[1]}/mongo-c-driver-${TERMUX_PKG_VERSION[1]}.tar.gz)
TERMUX_PKG_SHA256=(7178e5f0ee5e685d79110c4f51db056b52a8814e08684328c6041f1fc55293bc)
TERMUX_PKG_SHA256+=(2e59b9d38d600bd63ccc0b215dd44c6254a66eeb8085a5ac513748cd6220532e)
TERMUX_PKG_DEPENDS="libicu, libsnappy, libsasl, openssl"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DBUILD_VERSION=$TERMUX_PKG_VERSION
"

termux_step_post_get_source() {
	mv mongo-c-driver-1.22.2 mongo-c-driver

	for f in $TERMUX_SCRIPTDIR/tur/libmongoc/*.patch; do
		patch -p1 -d ./mongo-c-driver < $f
	done

	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DMONGOCRYPT_MONGOC_DIR=$TERMUX_PKG_SRCDIR/mongo-c-driver"
}

termux_step_pre_configure() {
	echo "!<arch>" > $TERMUX_PREFIX/lib/libresolv.a
}

termux_step_post_make_install() {
	rm $TERMUX_PREFIX/lib/libresolv.a
}
