TERMUX_PKG_HOMEPAGE=https://wiki.teamssix.com/cf
TERMUX_PKG_DESCRIPTION="Cloud Exploitation Framework"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@UtermuxBlog"
TERMUX_PKG_VERSION="0.4.0"
TERMUX_PKG_SRCURL=https://github.com/teamssix/cf/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=c0d68d36851e0cb638b41da00e300f08032c5a378b89029498fc05966512ff4a
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

