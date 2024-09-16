TERMUX_PKG_HOMEPAGE=https://owasp.org/www-project-juice-shop/
TERMUX_PKG_DESCRIPTION="A modern and sophisticated insecure web application"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="17.1.1"
TERMUX_PKG_SRCURL=https://github.com/juice-shop/juice-shop/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=9e8462174e2afc12546d781863037a4842d6168d6ee30d46eaa0cf11095da930
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="nodejs-lts"
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

TERMUX_PKG_NO_SHEBANG_FIX=true

termux_step_configure() {
	termux_setup_nodejs

	sed -i 's/"win32",/"android",/' package.json
}

termux_step_make() {
	if [ $TERMUX_ARCH = "arm" ]; then
		export NPM_CONFIG_ARCH=armv7l
	elif [ $TERMUX_ARCH = "x86_64" ]; then
		export NPM_CONFIG_ARCH=amd64
	elif [ $TERMUX_ARCH = "aarch64" ]; then
		export NPM_CONFIG_ARCH=arm64
	else
		termux_error_exit "Unsupported arch: $TERMUX_ARCH"
	fi

	export npm_config_arch=$NPM_CONFIG_ARCH
	export npm_config_build_from_source=true

	export GYP_DEFINES="android_ndk_path=''"
	npm install --jobs -1 --omit=dev
}

termux_step_make_install() {
	local install_prefix="$TERMUX_PREFIX/opt/juice-shop"
	rm -rf "$install_prefix"
	mkdir -p "$install_prefix"
	cp -Rf . $install_prefix/
	cat <<- EOF > $TERMUX_PREFIX/bin/juice-shop
	#!$TERMUX_PREFIX/bin/env sh

	cd $install_prefix
	npm start

	EOF
	chmod +x $TERMUX_PREFIX/bin/juice-shop
}

termux_step_create_debscripts() {
	# Pre-rm script to cleanup runtime-generated files.
	cat <<- PRERM_EOF > ./prerm
	#!$TERMUX_PREFIX/bin/sh

	echo "Deleting all files under $TERMUX_PREFIX/opt/juice-shop"
	rm -Rf $TERMUX_PREFIX/opt/juice-shop

	exit 0
	PRERM_EOF

	chmod 0755 prerm
}
