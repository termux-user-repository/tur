TERMUX_PKG_HOMEPAGE=https://github.com/microsoft/vscode
TERMUX_PKG_DESCRIPTION="Visual Studio Code"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.89.1"
TERMUX_PKG_SRCURL=git+https://github.com/microsoft/vscode
TERMUX_PKG_GIT_BRANCH="$TERMUX_PKG_VERSION"
TERMUX_PKG_DEPENDS="code-oss, openssl"
TERMUX_PKG_ANTI_BUILD_DEPENDS="code-oss"
TERMUX_PKG_BUILD_IN_SRC=true
# Chromium doesn't support i686 on Linux.
TERMUX_PKG_BLACKLISTED_ARCHES="i686"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"

termux_step_pre_configure() {
	TERMUX_PKG_SRCDIR+="/cli"
	TERMUX_PKG_BUILDDIR+="/cli"
}

termux_step_make() {
	termux_setup_rust

	cargo build --jobs $TERMUX_MAKE_PROCESSES --release --target $CARGO_TARGET_NAME
}

termux_step_make_install() {
	install -Dm700 $TERMUX_PKG_SRCDIR/target/$CARGO_TARGET_NAME/release/code $TERMUX_PREFIX/lib/code-oss/bin/code-tunnel-oss
}

termux_step_install_license() {
	mkdir -p $TERMUX_PREFIX/share/doc/code-tunnel-oss
	cp $TERMUX_PKG_SRCDIR/../LICENSE.txt $TERMUX_PREFIX/share/doc/code-tunnel-oss/LICENSE
	cp $TERMUX_PKG_SRCDIR/ThirdPartyNotices.txt $TERMUX_PREFIX/share/doc/code-tunnel-oss/ThirdPartyNotices.txt
}
