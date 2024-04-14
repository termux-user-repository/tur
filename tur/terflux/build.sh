TERMUX_PKG_HOMEPAGE=https://gitlab.com/TermuxTerflux/repo-arm
TERMUX_PKG_DESCRIPTION="With Special Managment"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@TermuxTerflux"
TERMUX_PKG_VERSION=1.0.1
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/etc/apt/sources.list.d
	echo "deb https://terflux-repo-termuxterflux-b97080d23d0779dd81a1b54f4f388ae63405.gitlab.io/ termux extras" > $TERMUX_PREFIX/etc/apt/sources.list.d/repo-arm.list
	## tur gpg key
	mkdir -p $TERMUX_PREFIX/etc/apt/trusted.gpg.d
	install -Dm600 $TERMUX_PKG_BUILDER_DIR/terflux.gpg $TERMUX_PREFIX/etc/apt/trusted.gpg.d/
	install -Dm600 $TERMUX_PKG_BUILDER_DIR/terflux.key $TERMUX_PREFIX/etc/apt/trusted.gpg.d/
}

termux_step_create_debscripts() {
	[ "$TERMUX_PACKAGE_FORMAT" = "pacman" ] && return 0
	echo "#!$TERMUX_PREFIX/bin/sh" > postinst
	echo "echo Downloading updated package list ..." >> postinst
	echo "apt update" >> postinst
	echo "exit 0" >> postinst
}
