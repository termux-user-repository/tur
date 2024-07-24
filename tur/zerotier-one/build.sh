TERMUX_PKG_HOMEPAGE=https://www.zerotier.com
TERMUX_PKG_DESCRIPTION="Creates virtual Ethernet networks of almost unlimited size."
# LICENSE: Business Source License 1.1 (BSL-1.1)
TERMUX_PKG_LICENSE="non-free"
TERMUX_PKG_LICENSE_FILE="LICENSE.txt"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.14.0"
TERMUX_PKG_SRCURL=https://github.com/zerotier/ZeroTierOne/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_DEPENDS="miniupnpc, natpmpc, openssl"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_SHA256=7191623a81b0d1b552b9431e8864dd3420783ee518394ac1376cee6aaf033291
TERMUX_PKG_SERVICE_SCRIPT=(
	'zerotier-one' 'exec su -c "'$TERMUX_PREFIX'/bin/zerotier-one -d"'
)

termux_step_configure() {
	termux_setup_rust

	sed \
	-e 's/usr\///g' \
	-e 's/sbin/bin/g' \
	-e 's/LDFLAGS=/LDFLAGS?=/' \
	-e 's/RUSTFLAGS=/RUSTFLAGS?=/' \
	-i make-linux.mk
	make echo_flags
}

termux_step_make() {
	export DESTDIR="${TERMUX_PREFIX}"
	make selftest -j $TERMUX_PKG_MAKE_PROCESSES ${QUIET_BUILD=""} ${TERMUX_PKG_EXTRA_MAKE_ARGS=""}
	# ./zerotier-selftest
	make -j $TERMUX_PKG_MAKE_PROCESSES $QUIET_BUILD ${TERMUX_PKG_EXTRA_MAKE_ARGS}
}
