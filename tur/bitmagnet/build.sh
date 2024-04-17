TERMUX_PKG_HOMEPAGE=https://github.com/bitmagnet-io/bitmagnet
TERMUX_PKG_DESCRIPTION="Self-hosted BitTorrent indexer with web UI"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.7.14"
TERMUX_PKG_SRCURL=https://github.com/bitmagnet-io/bitmagnet/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=5ec981c079b61f53b4280a62c299577c667d5152617ad049611d9abbb3087c2d
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	go build -ldflags "-X github.com/bitmagnet-io/bitmagnet/internal/version.GitTag=v$TERMUX_PKG_VERSION"
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/bitmagnet
}
