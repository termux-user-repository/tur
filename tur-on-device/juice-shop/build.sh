TERMUX_PKG_HOMEPAGE=https://owasp.org/www-project-juice-shop/
TERMUX_PKG_DESCRIPTION="A modern and sophisticated insecure web application. "
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="17.1.0"
TERMUX_PKG_SRCURL=https://github.com/juice-shop/juice-shop/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=335524444670efbd07d787dbe13072e9eb04105a832d121196febcf83103e50f
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="nodejs-lts"

termux_step_make() {
	sed -i 's/"win32",/"android",/' package.json
	export GYP_DEFINES="android_ndk_path=''"
	npm install --jobs -1 --omit=dev
}

termux_step_make_install() {
	local install_prefix="$TERMUX_PREFIX/opt/juice-shop"
	rm -rf "$install_prefix"
	mkdir -p "$install_prefix"
	cp -Rf . $install_prefix/
	cat << EOF > $TERMUX_PREFIX/bin/juice-shop
#!$TERMUX_PREFIX/bin/env sh

cd $install_prefix
npm start

EOF
	chmod +x $TERMUX_PREFIX/bin/juice-shop
}
