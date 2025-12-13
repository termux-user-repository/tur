TERMUX_PKG_HOMEPAGE=https://github.com/abhimanyu003/sttr
TERMUX_PKG_DESCRIPTION="Cli app to perform various operations on string"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.2.29"
TERMUX_PKG_SRCURL=https://github.com/abhimanyu003/sttr/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=ee9031656861671fd6103fb8d74cede331d92c39afd13b95d0b323debf26bf84
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang

	go mod init || :
	go mod tidy
}

termux_step_make() {
	go build -o sttr main.go
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/sttr
}
