TERMUX_PKG_HOMEPAGE=https://github.com/htr-tech/zphisher
TERMUX_PKG_DESCRIPTION="An automated phishing tool with 30+ templates"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.3.2
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/htr-tech/zphisher/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=c2b167d7fea616792f6ad2fe970e804815e555d801ab8f2bb19c966ac9c1ca1c
TERMUX_PKG_DEPENDS="curl, php, unzip, ncurses-utils, proot, resolv-conf"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install(){
	mkdir $TERMUX_PREFIX/opt/zphisher
	cd $TERMUX_PKG_SRCDIR
	cp  scripts/launch.sh $TERMUX_PREFIX/bin/zphisher
	cp -fr .github .sites LICENSE README.md zphisher.sh $TERMUX_PREFIX/opt/zphisher/
	chmod +x $TERMUX_PREFIX/bin/zphisher
}
