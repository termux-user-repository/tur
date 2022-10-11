TERMUX_PKG_HOMEPAGE=https://github.com/Bhaviktutorials/shark
TERMUX_PKG_DESCRIPTION="🦈Future Of Phishing With less delay!!🦈"
TERMUX_PKG_LICENSE="BSD-3-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="v2.5.1.0-beta"
TERMUX_PKG_SRCURL=https://github.com/Bhaviktutorials/shark/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=c57958d775af9119f28f36c05d713092aa0749e8d0e72738290cd538fd762642
TERMUX_PKG_DEPENDS="curl, php, unzip, p7zip, ncurses-utils, proot, resolv-conf, sox, ffmpeg, dialog"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install(){
	mkdir $TERMUX_PREFIX/share/shark
	cd $TERMUX_PKG_SRCDIR
	cp shark $TERMUX_PREFIX/bin/shark
	cp -fr setup file .github LICENSE manpage cloudshell shark $TERMUX_PREFIX/share/shark/
	7z x file && rm -rf file
	chmod +x $TERMUX_PREFIX/bin/shark
}:
