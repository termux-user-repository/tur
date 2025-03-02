TERMUX_PKG_HOMEPAGE=https://github.com/bitmagnet-io/bitmagnet
TERMUX_PKG_DESCRIPTION="Self-hosted BitTorrent indexer with web UI"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.10.0"
TERMUX_PKG_SRCURL=https://github.com/bitmagnet-io/bitmagnet/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=9a5783f1560442be76f7cd81a8b4a053a8864c17d6e57a8b0890ed784a1c18b8
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
