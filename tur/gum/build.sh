TERMUX_PKG_HOMEPAGE=https://github.com/charmbracelet/gum
TERMUX_PKG_DESCRIPTION="A tool for glamorous shell scripts"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.8.0
TERMUX_PKG_SRCURL=https://github.com/charmbracelet/gum/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=80d0000d8eaf1d577c76099a6747307df445ae66e368b99467d3493cce21c668
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_configure(){
	termux_setup_golang
}

termux_step_make(){
	go build -o gum
}

termux_step_make_install(){
	install -Dm755 -t "${TERMUX_PREFIX}"/bin gum
}
