# Origin repo: tur-hacking
TERMUX_PKG_HOMEPAGE=https://wiki.teamssix.com/cf
TERMUX_PKG_DESCRIPTION="Cloud Exploitation Framework"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@UtermuxBlog"
TERMUX_PKG_VERSION="0.4.2"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/teamssix/cf/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=a3ab590a1e6de5273746e03b700f9bc31bef8c7f779d604bdcce821993a674ea
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

