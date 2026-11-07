TERMUX_PKG_HOMEPAGE=https://github.com/zan8in/afrog
TERMUX_PKG_DESCRIPTION="A tool for finding vulnerabilities"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@UtermuxBlog"
TERMUX_PKG_VERSION="3.5.10"
TERMUX_PKG_SRCURL=https://github.com/zan8in/afrog/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=76cef5f297e6d7cb50ba1d0ce5b002f01f24a7088cc1678b97c16983bf5e5b0c
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_post_get_source() {
	termux_setup_golang

	go mod vendor
}

termux_step_make() {
	termux_setup_golang

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
