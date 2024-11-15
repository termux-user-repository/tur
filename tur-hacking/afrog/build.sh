TERMUX_PKG_HOMEPAGE=https://github.com/zan8in/afrog
TERMUX_PKG_DESCRIPTION="A tool for finding vulnerabilities"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@UtermuxBlog"
TERMUX_PKG_VERSION="3.1.2"
TERMUX_PKG_SRCURL=https://github.com/zan8in/afrog/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=00b8d4718f72d5b9f62b0ec156e9ee34bdd5370fee351f3f70daa783d156c063
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang

	go mod init || :
	go mod tidy
}

termux_step_make() {
	go build -v -a -o afrog cmd/afrog/main.go
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/afrog
}

termux_step_create_debscripts() {
	cat <<- EOF > ./prerm
	#!$TERMUX_PREFIX/bin/sh
	rm -rf $HOME/.config/afrog
	EOF
}
