TERMUX_PKG_HOMEPAGE=https://github.com/codedsprit/bfm
TERMUX_PKG_DESCRIPTION="🌼 ez file manager slokes in bash"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2023.08.02"
TERMUX_PKG_SRCURL=git+https://github.com/codedsprit/bfm
TERMUX_PKG_GIT_BRANCH="main"
TERMUX_PKG_SUGGESTS="vim"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	:
}

termux_step_make_install() {
	make install PREFIX=$TERMUX_PREFIX
}
