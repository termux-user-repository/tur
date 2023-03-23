TERMUX_PKG_HOMEPAGE=https://github.com/E343IO/shark
TERMUX_PKG_DESCRIPTION="🦈Future Of Phishing With less delay!!🦈"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@E343IO"
TERMUX_PKG_VERSION=2.5.1.0-git
_GIT_COMMIT=490e7a572a0a1b1b5a7768b20782771314917365
TERMUX_PKG_SRCURL=https://github.com/E343IO/shark/archive/$_GIT_COMMIT.zip
TERMUX_PKG_SHA256=ebda6793b75eaeaacf8b991daf6c002e10dbd41ec51017499f6dc442c3598163
TERMUX_PKG_DEPENDS="curl, php, unzip, p7zip, ncurses-utils, proot, resolv-conf, sox, ffmpeg, dialog"
TERMUX_PKG_ANTI_BUILD_DEPENDS="curl, php, unzip, p7zip, ncurses-utils, proot, resolv-conf, sox, ffmpeg, dialog"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install(){
	mkdir $TERMUX_PREFIX/share/shark
	cd $TERMUX_PKG_SRCDIR
	install -Dm700 -t $TERMUX_PREFIX/bin shark
	install -Dm600 -t $TERMUX_PREFIX/share/shark file setup shark
}
