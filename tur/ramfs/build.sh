TERMUX_PKG_HOMEPAGE=https://github.com/mars9/ramfs
TERMUX_PKG_DESCRIPTION="9P2000 server and client as a in-memory filesystem for long standing shell scripts"
TERMUX_PKG_LICENSE="ISC"
TERMUX_PKG_MAINTAINER="@flosnvjx"
TERMUX_PKG_VERSION=2015.01.12
TERMUX_PKG_SRCURL=https://github.com/mars9/ramfs/archive/e53e16537b5530cfb7a8fe08362456e5e5253285.tar.gz
TERMUX_PKG_SHA256=1a8e9a825d6a93996debd9801fa63f738f74a8c5d28e0ad03184e10ccd34c4dc
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_golang
	mkdir bin
	go build -o ./bin -trimpath ./cmd/*
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin bin/*
	install -Dm600 -t $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME README.*
}
