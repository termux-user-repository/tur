TERMUX_PKG_HOMEPAGE=https://github.com/Necoro/feed2imap-go
TERMUX_PKG_DESCRIPTION="feed2imap(1) reimplemented in Go that aggregating RSS/Atom/jsonfeed into folders of your IMAP mailbox"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION="1.7.2"
TERMUX_PKG_SRCURL="https://github.com/Necoro/feed2imap-go/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=b69103ddd8dd789e5174fd2469bc6c74ce29414291a9000de07e24ec569b0f1b
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_SUGGESTS="anacron"

termux_step_make() {
	termux_setup_golang
	mkdir bin
	go build -o ./bin -trimpath -ldflags "-s -w -X main.Version=${TERMUX_PKG_VERSION}"

	sed -e 's%^cache: "feed\.cache"$%cache: "'$TERMUX_CACHE_DIR/feed2imap-go/feed'"%' -i config.yml.example
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin bin/*
	install -Dm600 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README.* config.yml.example
}
