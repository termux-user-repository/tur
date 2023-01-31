TERMUX_PKG_HOMEPAGE=https://github.com/bloznelis/typioca
TERMUX_PKG_DESCRIPTION="Cozy typing speed tester"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.0.8"
TERMUX_PKG_SRCURL=https://github.com/bloznelis/typioca/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=6d40b65205af3707cf6da401fa4acee4bd86b173f82cb6ad334403e0e0117ba2
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
termux_step_pre_configure() {
	termux_setup_golang

	go mod init || :
	go mod tidy
}

termux_step_make() {
	go build -o typioca -ldflags="-w -s -X 'github.com/bloznelis/typioca/internal/base.Version=${TERMUX_PKG_VERSION}'"
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/typioca
}
