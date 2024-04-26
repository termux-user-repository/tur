TERMUX_PKG_HOMEPAGE=https://www.ratrabbit.nl/ratrabbit/software/xpenguins/index.html
TERMUX_PKG_DESCRIPTION="Xpenguins is a vintage application for Unix systems, showing penguins running, flying, falling etc. on the desktop, using windows as run paths."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@fervi"
TERMUX_PKG_VERSION="3.2.1"
TERMUX_PKG_SRCURL="https://www.ratrabbit.nl/downloads/xpenguins/xpenguins-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=b5a961684c461409527fef2cf266d8ae3823bd7a9cf79e678fa205e1de611c0f
TERMUX_PKG_DEPENDS="libxpm, gtk3, libandroid-glob"

termux_step_pre_configure() {
	LDFLAGS+=" -landroid-glob"
}
