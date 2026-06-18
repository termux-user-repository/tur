TERMUX_PKG_HOMEPAGE=https://github.com/SrErikCoderx/android-openjdk_8-build
TERMUX_PKG_DESCRIPTION="Java 8 JDK and JRE for Android/Termux (OpenJDK 8)"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@SrErikCoderx"
TERMUX_PKG_VERSION="8.0.502"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/SrErikCoderx/android-openjdk_8-build/archive/refs/tags/v8u502-build4.tar.gz
TERMUX_PKG_SHA256=0da4a7cb3f26cce49c72547f52cafd7bb08afcda72f1d2d3811c6da0974570a9
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_NO_STRIP=true
TERMUX_PKG_NO_ELF_CLEANER=true
TERMUX_PKG_DEPENDS="freetype"
TERMUX_PKG_RECOMMENDS="alsa-plugins, libandroid-shmem, libandroid-spawn, libiconv, libjpeg-turbo, littlecms, zlib"

termux_step_make() {
	cd "$TERMUX_PKG_SRCDIR"
	export TUR_BUILD=1
	sed -i '/dpkg-deb --build/s/^/# /' debpack.sh
	case "$TERMUX_ARCH" in
		arm)   bash ci_build_arch_aarch32.sh ;;
		i686)  bash ci_build_arch_x86.sh ;;
		*)     bash ci_build_arch_${TERMUX_ARCH}.sh ;;
	esac
}

termux_step_make_install() {
	cd "$TERMUX_PKG_SRCDIR"
	cp -a debdata/data/data/com.termux/files/usr/. "$TERMUX_PREFIX/"
}

termux_step_create_debscripts() {
	cp "$TERMUX_PKG_SRCDIR/debdata/DEBIAN/postinst" ./postinst
	cp "$TERMUX_PKG_SRCDIR/debdata/DEBIAN/prerm"    ./prerm
}
