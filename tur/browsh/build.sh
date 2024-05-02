TERMUX_PKG_HOMEPAGE=http://www.brow.sh/
TERMUX_PKG_DESCRIPTION="A fully-modern text-based browser, rendering to TTY and browsers"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.8.3
TERMUX_PKG_SRCURL=https://github.com/browsh-org/browsh/archive/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=88462530dbfac4e17c8f8ba560802d21042d90236043e11461a1cfbf458380ca
TERMUX_PKG_DEPENDS="firefox"
TERMUX_PKG_ANTI_BUILD_DEPENDS="firefox"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_post_get_source() {
	local extension_url="https://github.com/browsh-org/browsh/releases/download/v$TERMUX_PKG_VERSION/browsh-$TERMUX_PKG_VERSION.xpi"
	local extension_sha256="c0b72d7c61c30a0cb79cc1bf9dcf3cdaa3631ce029f1578e65c116243ed04e16"
	local extension_path="$TERMUX_PKG_CACHEDIR/$(basename $extension_url)"

	termux_download $extension_url $extension_path $extension_sha256

	cp -f $extension_path $TERMUX_PKG_SRCDIR/interfacer/src/browsh/browsh.xpi
}

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	cd $TERMUX_PKG_SRCDIR/interfacer
	go build -x -modcacherw -o ./bin/browsh ./cmd/browsh
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin ./interfacer/bin/browsh
}
