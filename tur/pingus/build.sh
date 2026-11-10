TERMUX_PKG_HOMEPAGE="https://pingus.seul.org/"
TERMUX_PKG_DESCRIPTION="A free Lemmings-like puzzle game"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="0.8.0-2026.10.29"
TERMUX_PKG_SRCURL="https://github.com/Pingus/pingus/archive/ffe3851f1f9f9f5c245887d89ab4a56399c13769.tar.gz"
TERMUX_PKG_SHA256="cdf2a4bce6ce03b8055f492f37fa68e8d2e4e7b4c27871bf727dadb162d710ed"
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="libmodplug, libsigc++-2.0, openal-soft, opengl, pingus-data, sdl2 | sdl2-compat, sdl2-image"
TERMUX_PKG_BUILD_DEPENDS="glm"
TERMUX_PKG_GROUPS="games"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DPINGUS_NO_XDGCPP=ON"

termux_step_pre_configure() {
	CXXFLAGS+=" -UANDROID"
}
