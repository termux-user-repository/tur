TERMUX_PKG_HOMEPAGE=https://github.com/SrErikCoderx/android-openjdk_8-build
TERMUX_PKG_DESCRIPTION="Java 8 JDK and JRE for Android/Termux (OpenJDK 8)"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@SrErikCoderx"
TERMUX_PKG_VERSION="8.0.502"
TERMUX_PKG_REVISION=4
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_HAS_DEBUG=false
TERMUX_PKG_NO_STRIP=true
TERMUX_PKG_NO_ELF_CLEANER=true
TERMUX_PKG_DEPENDS="freetype"
TERMUX_PKG_RECOMMENDS="alsa-plugins, libandroid-shmem, libandroid-spawn, libiconv, libjpeg-turbo, littlecms, zlib"

TERMUX_PKG_UNDEF_SYMBOLS_FILES="*/libsaproc.so"
_OPENJDK8_TAG=v8u502-build4

termux_step_make_install() {
	local deb_arch="$TERMUX_ARCH"
	local deb_url="https://github.com/SrErikCoderx/android-openjdk_8-build/releases/download/${_OPENJDK8_TAG}/openjdk-8_${TERMUX_PKG_VERSION}_${deb_arch}.deb"
	local deb_file="$TERMUX_PKG_CACHEDIR/openjdk-8_${TERMUX_PKG_VERSION}_${deb_arch}.deb"
	local extract_dir="$TERMUX_PKG_TMPDIR/openjdk8-extract"

	termux_download "$deb_url" "$deb_file" SKIP_CHECKSUM

	rm -rf "$extract_dir"
	mkdir -p "$extract_dir"

	dpkg-deb -x "$deb_file" "$extract_dir"
	cp -a "$extract_dir/data/data/com.termux/files/usr/." "$TERMUX_PREFIX/"
}

termux_step_create_debscripts() {
	local deb_arch="$TERMUX_ARCH"
	local deb_url="https://github.com/SrErikCoderx/android-openjdk_8-build/releases/download/${_OPENJDK8_TAG}/openjdk-8_${TERMUX_PKG_VERSION}_${deb_arch}.deb"
	local deb_file="$TERMUX_PKG_CACHEDIR/openjdk-8_${TERMUX_PKG_VERSION}_${deb_arch}.deb"
	local ctrl_dir="$TERMUX_PKG_TMPDIR/openjdk8-ctrl"

	rm -rf "$ctrl_dir"
	mkdir -p "$ctrl_dir"
	dpkg-deb -e "$deb_file" "$ctrl_dir"

	if [ -f "$ctrl_dir/postinst" ]; then
		cp "$ctrl_dir/postinst" ./postinst
	fi
	if [ -f "$ctrl_dir/prerm" ]; then
		cp "$ctrl_dir/prerm" ./prerm
	fi
}
