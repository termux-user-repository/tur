TERMUX_PKG_HOMEPAGE=https://monkey.org/~dugsong/dsniff/
TERMUX_PKG_DESCRIPTION="Collection of tools for network auditing and penetration testing"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_PKG_VER="2.4b1"
_DEBIAN_REVISION="31"
TERMUX_PKG_VERSION="$_PKG_VER+debian-$_DEBIAN_REVISION"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=(https://monkey.org/~dugsong/dsniff/beta/dsniff-$_PKG_VER.tar.gz)
TERMUX_PKG_SRCURL+=(https://ftp.debian.org/debian/pool/main/d/dsniff/dsniff_$TERMUX_PKG_VERSION.debian.tar.xz)
TERMUX_PKG_SHA256=(a9803a7a02ddfe5fb9704ce86f0ffc48453c321e88db85810db411ba0841152a)
TERMUX_PKG_SHA256+=(1e2a3a3dc5a76c5a6a0d0554736f0a67f02a6329f064080aeb6b7f0e3c74ac80)
TERMUX_PKG_DEPENDS="libdb, libnet, libnids, libnsl, libpcap, libtirpc, openssl"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--oldincludedir=$TERMUX_PREFIX/include
--without-x
--with-libtirpc=yes
"

termux_step_post_get_source() {
	# Apply bundled patches via series
	while IFS='' read -r patch || [[ -n "${patch}" ]]; do
		# Drop 39_libtirpc.patch
		if [ "${patch}" = "39_libtirpc.patch" ]; then
			continue
		fi
		echo "** Applying patch ${patch}"
		patch -Np1 < "debian/patches/${patch}"
	done < debian/patches/series
}

termux_step_pre_configure() {
	CFLAGS+=" -Wno-error=implicit-int"
	CPPFLAGS+=" -Wno-error=implicit-int"

	autoreconf -fiv
}
