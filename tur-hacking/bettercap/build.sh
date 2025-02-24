TERMUX_PKG_HOMEPAGE=https://www.bettercap.org/
TERMUX_PKG_DESCRIPTION="The Swiss Army knife for 802.11, BLE, IPv4 and IPv6 networks reconnaissance and MITM attacks. "
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_VERSION="2.41.0"
TERMUX_PKG_MAINTAINER="1q23lyc45"
TERMUX_PKG_SRCURL=https://github.com/bettercap/bettercap/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=6c2161acb85599a066bea2d28805f72cde68c13fefb8e67c5c72f3c31c3372c1
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_BUILD_DEPENDS="libusb, libpcap, root-repo, libnetfilter-queue"
TERMUX_PKG_DEPENDS="libusb, libpcap, root-repo, libnetfilter-queue"

termux_step_make() {
	termux_setup_golang
	make
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin bettercap
}
