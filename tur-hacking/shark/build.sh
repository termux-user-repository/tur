TERMUX_PKG_HOMEPAGE=https://github.com/E343IO/shark
TERMUX_PKG_DESCRIPTION="🦈Future Of Phishing With less delay!!🦈"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@E343IO"
TERMUX_PKG_VERSION=2.5.1
#_GIT_COMMIT=490e7a572a0a1b1b5a7768b20782771314917365
TERMUX_PKG_SRCURL=https://github.com/E343IO/shark/archive/refs/tags/v${TERMUX_PKG_VERSION}.zip
TERMUX_PKG_SHA256=b6cf74584f85acd9a110c04f398b1498972159c4d70a617abd0444e5c777f382
TERMUX_PKG_DEPENDS="curl, wget, php, unzip, p7zip, ncurses-utils, proot, resolv-conf, sox, ffmpeg, dialog"
TERMUX_PKG_ANTI_BUILD_DEPENDS="curl, wget, php, unzip, p7zip, ncurses-utils, proot, resolv-conf, sox, ffmpeg, dialog"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install(){
	mkdir $TERMUX_PREFIX/share/shark
	cd $TERMUX_PKG_SRCDIR
	install -Dm700 -t $TERMUX_PREFIX/bin shark
	install -Dm600 -t $TERMUX_PREFIX/share/shark file setup shark
}
