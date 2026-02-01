TERMUX_PKG_HOMEPAGE=https://github.com/freegish/freegish
TERMUX_PKG_DESCRIPTION="A physics based platformer"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="IntinteDAO"
TERMUX_PKG_VERSION=1.53
TERMUX_PKG_SRCURL=https://github.com/freegish/freegish/archive/refs/heads/master.zip
TERMUX_PKG_SHA256=fbecdaf4b3988c5b8efd867d4bc1d27c275ee009da960f448e05cc81205c6f93
TERMUX_PKG_DEPENDS="libvorbis, openal-soft, sdl2, libpng, zlib"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DINSTALL_FHS=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5"
TERMUX_PKG_GROUPS="games"
