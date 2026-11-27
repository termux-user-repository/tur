TERMUX_PKG_HOMEPAGE=https://github.com/Spectra010s/gshell
TERMUX_PKG_DESCRIPTION="Terminal client for Google Cloud Shell"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@Spectra010s"
TERMUX_PKG_VERSION="2.0.1"
TERMUX_PKG_SRCURL=https://github.com/Spectra010s/gshell/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=70370f8dbb1b2e8b7dbb0c55747640542d19de4dd457c836f74baaac98061fa5
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_golang

	cd "$TERMUX_PKG_SRCDIR"
	go build \
		-trimpath \
		-ldflags "-s -w -X gshell/cmd.version=${TERMUX_PKG_VERSION}" \
		-o gshell .
}

termux_step_make_install() {
	install -Dm755 gshell "$TERMUX_PREFIX/bin/gshell"
}
