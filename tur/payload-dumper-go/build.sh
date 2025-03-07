TERMUX_PKG_HOMEPAGE="https://github.com/ssut/payload-dumper-go"
TERMUX_PKG_DESCRIPTION="An android OTA payload dumper written in Go"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_VERSION="1.3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_SRCURL=https://github.com/ssut/payload-dumper-go/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=d7ba33a80c539674c0b63443b8c6dd9c2040ec996323f38ffe72e024d302eb2d
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="liblzma"

__prepare_zstd() {
	pushd "$TERMUX_PKG_SRCDIR"
	cd vendor/github.com/valyala/gozstd
	make update-zstd-source
	cd zstd/lib
	ZSTD_LEGACY_SUPPORT=0 MOREFLAGS=-fPIC make clean libzstd.a -j $TERMUX_PKG_MAKE_PROCESSES
	cd ../..
	mv zstd/lib/libzstd.a libzstd_linux_$GOARCH.a
	popd
}

termux_step_post_get_source() {
	termux_setup_golang

	go mod vendor
}

termux_step_make() {
	__prepare_zstd

	termux_setup_golang
	go build -o payload-dumper-go
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin payload-dumper-go
}
