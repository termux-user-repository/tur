TERMUX_PKG_HOMEPAGE=https://github.com/mongodb/mongo-c-driver
TERMUX_PKG_DESCRIPTION="A library providing useful routines related to building, parsing, and iterating BSON documents"
TERMUX_PKG_LICENSE="Apache-2.0, custom"
TERMUX_PKG_LICENSE_FILE="COPYING, src/libbson/THIRD_PARTY_NOTICES"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.30.3
TERMUX_PKG_REVISION=3
TERMUX_PKG_SRCURL=https://github.com/mongodb/mongo-c-driver/releases/download/$TERMUX_PKG_VERSION/mongo-c-driver-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=9f42eb507e8c591546dc9c584230a6f71127842cb597cc4ab219d1ebe251e7af
# NOTE: No need to revbump libbson if libicu bumps major version
TERMUX_PKG_BUILD_DEPENDS="libicu, libsasl, openssl, zlib, zstd"
TERMUX_PKG_CONFLICTS="libmongoc (<< 1.30.3)"
TERMUX_PKG_BREAKS="libmongoc (<< 1.30.3)"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX
-DCMAKE_INSTALL_LIBDIR=lib
-DENABLE_TESTS=OFF
"

termux_step_pre_configure() {
	echo "!<arch>" > $TERMUX_PREFIX/lib/libresolv.a
}

termux_step_post_make_install() {
	rm $TERMUX_PREFIX/lib/libresolv.a
	# Provided by libmongoc-static
	rm $TERMUX_PREFIX/lib/libmongoc-static*.a
}

termux_step_post_massage() {
	find . ! -type d \
		! -wholename "./lib/libbson*" \
		! -wholename "./include/libbson*" \
		! -wholename "./lib/pkgconfig/libbson*" \
		! -wholename "./lib/cmake/bson*" \
		! -wholename "./lib/cmake/libbson*" \
		-exec rm -f '{}' \;
	find . -type d -empty -delete

	# Do not forget to bump revision of reverse dependencies and rebuild them
	# after SOVERSION is changed.
	local _SOVERSION_GUARD_FILES="
lib/libbson-1.0.so
"
	local f
	for f in ${_SOVERSION_GUARD_FILES}; do
		if [ ! -e "${f}" ]; then
			termux_error_exit "SOVERSION guard check failed."
		fi
	done
}
