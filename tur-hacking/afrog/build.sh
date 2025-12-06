TERMUX_PKG_HOMEPAGE=https://github.com/zan8in/afrog
TERMUX_PKG_DESCRIPTION="A tool for finding vulnerabilities"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@UtermuxBlog"
TERMUX_PKG_VERSION="3.2.6"
TERMUX_PKG_SRCURL=https://github.com/zan8in/afrog/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=512e50267c09f9d929f241620fd3587759a9162697e489a023437dc4bb56b623
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_post_get_source() {
	curl -L \
		"https://github.com/zan8in/afrog/commit/e01cc41151b94a987b8b3d0327a4dae355dbd4ce.patch" \
		-o "$TERMUX_PKG_SRCDIR/web.patch"
	cd "$TERMUX_PKG_SRCDIR"
	git apply "$TERMUX_PKG_SRCDIR/web.patch"
}

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
