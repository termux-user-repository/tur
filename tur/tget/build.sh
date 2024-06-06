TERMUX_PKG_HOMEPAGE=https://github.com/sweetbbak/tget
TERMUX_PKG_DESCRIPTION="An open source Go backend"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.1"
TERMUX_PKG_SRCURL="https://github.com/sweetbbak/tget/archive/refs/tags/V${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=4df1b21a17de415aa380e30399809182a0bcb6b853b7a26633cefa00709781b4
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
termux_step_make()
{
export CGO_ENABLED=0
termux_setup_golang
go build -o tget
}
termux_step_make_install(){
install -m700 tget "${TERMUX_PREFIX}"/bin/tget
}
