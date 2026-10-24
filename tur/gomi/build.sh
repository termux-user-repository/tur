TERMUX_PKG_HOMEPAGE=https://gomi.dev
TERMUX_PKG_DESCRIPTION="Safer alternative to the rm command, with a trash can you can restore from"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Zeldris <80939130+zeldrisho@users.noreply.github.com>"
TERMUX_PKG_VERSION="1.7.0"
TERMUX_PKG_SRCURL=https://github.com/babarot/gomi/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=5f1b135ef0531e85020bbcd840b3645bdc1c6811ddd3b187fadf722d8f1251c8
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	termux_setup_golang

	local _ldflags="
		-s -w
		-X main.version=v${TERMUX_PKG_VERSION}
		-X main.revision=termux
		-X main.buildDate=$(date -u +%Y-%m-%dT%H:%M:%SZ)
	"
	go build -ldflags "${_ldflags}" -o gomi .
}

termux_step_make_install() {
	install -Dm700 gomi -t "${TERMUX_PREFIX}/bin/"
}
