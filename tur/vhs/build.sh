TERMUX_PKG_HOMEPAGE=https://github.com/charmbracelet/vhs
TERMUX_PKG_DESCRIPTION="Your CLI home video recorder"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.1.1
TERMUX_PKG_SRCURL=https://github.com/charmbracelet/vhs/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=d5d6dddd8f9fd2beb6d1ea232efaa1c9dbfa4e53011d2aebdbe830d952665776
TERMUX_PKG_DEPENDS="ttyd"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_configure(){
	termux_setup_golang
}

termux_step_make(){
	go build -o vhs
}

termux_step_make_install(){
	install -Dm755 -t "${TERMUX_PREFIX}"/bin vhs
}
