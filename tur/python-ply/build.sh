TERMUX_PKG_HOMEPAGE=https://www.dabeaz.com/ply/
TERMUX_PKG_DESCRIPTION="Implementation of lex and yacc in Python"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="3.11"
TERMUX_PKG_SRCURL="https://github.com/dabeaz/ply/archive/refs/tags/$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=928c5642612f4710b168d3c49c25f6ece2913a5e8d1c5e37fde5d6162fec3fd2
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_SETUP_PYTHON=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_DEPENDS="python"

termux_step_pre_configure() {
	# use setup.py to build rather than make
	rm Makefile
	# extract license for termux_step_install_license
	head -n32 ply/lex.py > LICENSE
}
