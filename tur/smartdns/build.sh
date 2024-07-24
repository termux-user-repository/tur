TERMUX_PKG_HOMEPAGE=https://github.com/pymumu/smartdns
TERMUX_PKG_DESCRIPTION="A local DNS server to obtain the fastest website IP for the best Internet experience, support DoT, DoH"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=46
TERMUX_PKG_SRCURL=https://github.com/pymumu/smartdns/archive/refs/tags/Release$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=6594d21c0e354b67d4b5918e11eff21e6314e247b9e6e28be1ece4168c368fc1
TERMUX_PKG_DEPENDS="libandroid-glob, libc++, openssl"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_VERSION_REGEXP="\d+"

termux_pkg_auto_update() {
	# Get the newest tag:
	local tag
	tag="$(termux_github_api_get_tag "${TERMUX_PKG_SRCURL}" "${TERMUX_PKG_UPDATE_TAG_TYPE}")"
	# check if this is not a release:
	if grep -qP "^Release${TERMUX_PKG_UPDATE_VERSION_REGEXP}\$" <<<"$tag"; then
		termux_pkg_upgrade_version "$tag"
	else
		echo "WARNING: Skipping auto-update: Not a release($tag)"
	fi
}

termux_step_configure() {
	LDFLAGS+=" -landroid-glob"
}

termux_step_make() {
	make -j $TERMUX_PKG_MAKE_PROCESSES \
			PREFIX="$PREFIX" \
			SBINDIR="$PREFIX/bin" \
			SYSCONFDIR="$PREFIX/etc" \
			RUNSTATEDIR="$PREFIX/var/run"
}

termux_step_make_install() {
	make install -j $TERMUX_PKG_MAKE_PROCESSES \
			PREFIX="$PREFIX" \
			SBINDIR="$PREFIX/bin" \
			SYSCONFDIR="$PREFIX/etc" \
			RUNSTATEDIR="$PREFIX/var/run"
}
