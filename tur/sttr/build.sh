TERMUX_PKG_HOMEPAGE=https://github.com/abhimanyu003/sttr
TERMUX_PKG_DESCRIPTION="Cli app to perform various operations on string"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.2.16
TERMUX_PKG_SRCURL=https://github.com/abhimanyu003/sttr/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=ef635e1f12900cf96655c410aa225b4ea7fb6c40687ef4d35927c6f9fffcd674
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
