TERMUX_PKG_HOMEPAGE=https://github.com/freegish/freegish
TERMUX_PKG_DESCRIPTION="A physics based platformer"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="IntinteDAO"
TERMUX_PKG_VERSION=2.0.0
TERMUX_PKG_SRCURL="https://github.com/freegish/freegish/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=b71b8d53ced5c8156ac85dabb60ba08713f14ab0849461e327e1b19517b9cb66
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="freegish-data, libglvnd, libpng, libvorbis, openal-soft, sdl2, zlib"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DINSTALL_FHS=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5"
TERMUX_PKG_GROUPS="games"
