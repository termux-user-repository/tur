TERMUX_PKG_HOMEPAGE=https://github.com/SuperTux/squirrel
TERMUX_PKG_DESCRIPTION="Lightweight, high-level, embeddable programming language (SuperTux fork)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=2024.12.31
TERMUX_PKG_SRCURL=git+https://github.com/SuperTux/squirrel.git
TERMUX_PKG_GIT_BRANCH=master

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DSQ_DISABLE_INTERPRETER=ON"

termux_step_pre_configure() {
	# Force using the provided CMakeLists.txt and ensure it builds correctly for Termux
	sed -i 's/cmake_minimum_required(VERSION [0-9.]*)/cmake_minimum_required(VERSION 3.10)/' CMakeLists.txt
}
