TERMUX_PKG_HOMEPAGE=https://github.com/sweetbbak/go-moreutils
TERMUX_PKG_DESCRIPTION="coreutils with some more modern features, written in go"
# LICENSE: CUSTOM, only has credits
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="README.md"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=68a1b6ef2190295e976a825eaaca4ff9f0f7a027
_COMMIT_DATE=2024.01.30
TERMUX_PKG_VERSION=0.0.${_COMMIT_DATE//./}
TERMUX_PKG_SRCURL=https://github.com/sweetbbak/go-moreutils/archive/$_COMMIT.zip
TERMUX_PKG_SHA256=064f6707fc73fd171fc02710d9002d68479a030e9fbbe0e42735530c4a4f86f3
TERMUX_PKG_DEPENDS="file"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_golang

	bash ./build.sh
}

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/opt/go-moreutils/bin
	cp -Rfv ./bin/* $TERMUX_PREFIX/opt/go-moreutils/bin/
}
