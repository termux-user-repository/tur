TERMUX_PKG_HOMEPAGE=https://github.com/bloznelis/typioca
TERMUX_PKG_DESCRIPTION="Cozy typing speed tester"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.8.0"
TERMUX_PKG_SRCURL=https://github.com/bloznelis/typioca/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=b55213d13f6cffb913a517df3024eacb1966cc5568e57609e38bd591b64d7ad4
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
