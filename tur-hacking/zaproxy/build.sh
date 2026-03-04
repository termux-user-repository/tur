TERMUX_PKG_HOMEPAGE="https://www.zaproxy.org/"
TERMUX_PKG_DESCRIPTION="Integrated penetration testing tool for finding vulnerabilities in web applications"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.17.0"
TERMUX_PKG_SRCURL="https://github.com/zaproxy/zaproxy/releases/download/v${TERMUX_PKG_VERSION}/ZAP_${TERMUX_PKG_VERSION}_Linux.tar.gz"
TERMUX_PKG_SHA256=efe799aaa3627db683b43f00c9c210aea0b75c00cc8f0a0f0434d12bb3ddde5a
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="openjdk-17, openjdk-17-x"
TERMUX_PKG_ANTI_BUILD_DEPENDS="openjdk-17, openjdk-17-x"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	local install_prefix="$TERMUX_PREFIX/share/zap"
	rm -rf "$install_prefix"
	mkdir -p "$install_prefix"
	cp -Rf . $install_prefix/
	ln -sfr $install_prefix/zap.sh $TERMUX_PREFIX/bin/zaproxy
	mkdir -p "$TERMUX_PREFIX/share/pixmaps"
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install -y graphicsmagick-imagemagick-compat
	convert zap.ico[0] -resize 64x64 $TERMUX_PREFIX/share/pixmaps/zap.png
	install -Dm644 -t "${TERMUX_PREFIX}/share/applications" "${TERMUX_PKG_BUILDER_DIR}/zap.desktop"
}
