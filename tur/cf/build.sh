TERMUX_PKG_HOMEPAGE=https://wiki.teamssix.com/cf
TERMUX_PKG_DESCRIPTION="Cloud Exploitation Framework"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@UtermuxBlog"
TERMUX_PKG_VERSION="0.4.1"
TERMUX_PKG_SRCURL=https://github.com/teamssix/cf/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=7abc6a48ac91513c953bc9bc0cbf16aa35eb08f4a4df9d3947b140840f4f1945
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang

	go mod init || :
	go mod tidy
}

termux_step_make() {
        cd $TERMUX_PKG_SRCDIR
	go build -o cf
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/cf
}

