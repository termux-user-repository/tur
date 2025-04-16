TERMUX_PKG_HOMEPAGE=https://github.com/abhimanyu003/sttr
TERMUX_PKG_DESCRIPTION="Cli app to perform various operations on string"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.2.25"
TERMUX_PKG_SRCURL=https://github.com/abhimanyu003/sttr/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=0369a28a944f3f2f3c5bde527572acafbeeeee1a5cf158c1dc8dd5e9f068e059
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
