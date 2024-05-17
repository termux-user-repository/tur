TERMUX_PKG_HOMEPAGE=https://github.com/shadow1ng/fscan
TERMUX_PKG_DESCRIPTION="A comprehensive intranet scanning tool"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@UtermuxBlog"
TERMUX_PKG_VERSION="1.8.1"
TERMUX_PKG_REVISION=2
# Why Use Git: https://github.com/shadow1ng/fscan/issues/218
TERMUX_PKG_SRCURL=git+https://github.com/shadow1ng/fscan
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_GIT_BRANCH="main"

termux_step_pre_configure() {
	termux_setup_golang

	go mod init || :
	go mod tidy
}

termux_step_make() {
	cd $TERMUX_PKG_SRCDIR
	go build -o fscan main.go
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/fscan
}
