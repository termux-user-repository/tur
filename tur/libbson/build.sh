TERMUX_PKG_HOMEPAGE=https://github.com/mongodb/mongo-c-driver
TERMUX_PKG_DESCRIPTION="A library providing useful routines related to building, parsing, and iterating BSON documents"
TERMUX_PKG_LICENSE="Apache-2.0, MIT"
TERMUX_PKG_LICENSE_FILE="COPYING, src/libbson/THIRD_PARTY_NOTICES"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.22.2
TERMUX_PKG_REVISION=3
TERMUX_PKG_SRCURL=https://github.com/mongodb/mongo-c-driver/releases/download/$TERMUX_PKG_VERSION/mongo-c-driver-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=2e59b9d38d600bd63ccc0b215dd44c6254a66eeb8085a5ac513748cd6220532e
# NOTE: No need to revbump libbson if libicu bumps major version
TERMUX_PKG_BUILD_DEPENDS="libicu, libsasl, openssl, zlib, zstd"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DENABLE_TESTS=OFF
"

termux_step_pre_configure() {
	echo "!<arch>" > $TERMUX_PREFIX/lib/libresolv.a
}

termux_step_post_make_install() {
	rm $TERMUX_PREFIX/lib/libresolv.a
}

termux_step_post_massage() {
	find . ! -type d \
		! -wholename "./lib/libbson*" \
		! -wholename "./include/libbson*" \
		! -wholename "./lib/pkgconfig/libbson*" \
		-exec rm -f '{}' \;
	find . -type d -empty -delete
}

termux_step_post_massage() {
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
