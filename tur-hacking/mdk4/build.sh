TERMUX_PKG_HOMEPAGE=https://github.com/aircrack-ng/mdk4
TERMUX_PKG_DESCRIPTION="MDK is a proof-of-concept tool to exploit common IEEE 802.11 protocol weaknesses"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_VERSION=4.2
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/aircrack-ng/mdk4/archive/c6a35994b2f0d87d79ce9a072b84a486775d8ee4.zip
TERMUX_PKG_SHA256=9eb57c1b70d0d4da6baccea90c437fb095e401f33256b52336b4b420cf32dc9d
TERMUX_PKG_DEPENDS="aircrack-ng, libnl, libpcap"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	CFLAGS+=" -Wno-implicit-function-declaration"
}
