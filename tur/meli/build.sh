TERMUX_PKG_HOMEPAGE=https://meli.delivery/
TERMUX_PKG_DESCRIPTION="Terminal e-mail client and e-mail client library"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.8.10"
TERMUX_PKG_SRCURL=git+https://github.com/meli/meli
TERMUX_PKG_BUILD_IN_SRC=true
# gpgme and notmuch are dlopened.
TERMUX_PKG_DEPENDS="gpgme, libcurl, libsqlite, notmuch, openssl, pcre2"
TERMUX_PKG_ANTI_BUILD_DEPENDS="gpgme, notmuch"
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
# `meli` assumes that `(u)size_t` is 64-bit, but it is not true on 32-bit Android.
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	# Install binary
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/meli

	# Install docs
	VERBOSE=1 make install-doc PREFIX="$PREFIX"
}
