TERMUX_PKG_HOMEPAGE=https://github.com/varbhat/exatorrent
TERMUX_PKG_DESCRIPTION="Self-hostable, easy-to-use, lightweight, and feature-rich torrent client written in Go"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.1.0"
TERMUX_PKG_SRCURL=https://github.com/varbhat/exatorrent/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=56f932a6c5950bc0035c81726ffbd2da188b6df4b19d8dd446a4f417bf52c8e3
TERMUX_PKG_DEPENDS="libc++"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_GO_USE_OLDER=true

termux_step_host_build() {
	termux_setup_nodejs

	cp -r $TERMUX_PKG_SRCDIR/internal/web ./web
	cd web
	npm install
	npm run build
}

termux_step_pre_configure() {
	cp -r $TERMUX_PKG_HOSTBUILD_DIR/web/build $TERMUX_PKG_SRCDIR/internal/web/

	termux_setup_golang
	rm -rf $GOROOT

	termux_setup_golang
	( cd "$GOROOT"; . ${TERMUX_PKG_BUILDER_DIR}/fix-hardcoded-etc-resolv-conf.sh )
}

termux_step_make() {
	go build -trimpath -buildmode=pie -ldflags '-extldflags "-s -w"' -o build/exatorrent exatorrent.go
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/build/exatorrent
}
