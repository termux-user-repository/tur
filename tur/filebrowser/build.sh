TERMUX_PKG_HOMEPAGE=https://filebrowser.org/
TERMUX_PKG_DESCRIPTION="Web file browser based on Go"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.30.0"
TERMUX_PKG_SRCURL="https://github.com/filebrowser/filebrowser/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=179270033623213c4c53af59384b585c968d407762e8810816c118afc3c1f02a
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_QUIET_BUILD=false

termux_step_pre_configure() {
	termux_setup_golang
	termux_setup_nodejs
}

termux_step_make() {
	make build-frontend
	go build
}

termux_step_make_install() {
	install -Dm700 filebrowser $TERMUX_PREFIX/bin/
}
