TERMUX_PKG_HOMEPAGE=https://osslugaru.gitlab.io
TERMUX_PKG_DESCRIPTION="Lugaru HD, free and open source ninja rabbit fighting game"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION="1.2"
TERMUX_PKG_SRCURL=https://github.com/osslugaru/lugaru/releases/download/${TERMUX_PKG_VERSION}/lugaru-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=f3ea477caf78911c69939fbdc163f9f6517c7ef2267e716a0e050be1a166ef97
TERMUX_PKG_DEPENDS="sdl2, glu, openal-soft, lugaru-data"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX
-DSYSTEM_INSTALL=ON
-DCMAKE_INSTALL_BINDIR=bin
-DCMAKE_INSTALL_DATADIR=share/games
-DCMAKE_POLICY_VERSION_MINIMUM=3.5
"

termux_step_pre_configure() {
	export LDFLAGS+=" -Wl,--no-as-needed,-lOpenSLES,--as-needed"
}
