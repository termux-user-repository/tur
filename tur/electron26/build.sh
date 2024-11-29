TERMUX_PKG_HOMEPAGE=https://github.com/electron/electron
TERMUX_PKG_DESCRIPTION="Build cross-platform desktop apps with JavaScript, HTML, and CSS"
TERMUX_PKG_LICENSE="MIT, BSD 3-Clause"
TERMUX_PKG_MAINTAINER="Chongyun Lee <uchkks@protonmail.com>"
TERMUX_PKG_VERSION=26.6.10
TERMUX_PKG_SRCURL=git+https://github.com/electron/electron
TERMUX_PKG_DEPENDS="electron-deps"
TERMUX_PKG_ANTI_BUILD_DEPENDS="electron-deps"
# Chromium-based application doesn't support i686 on Linux.
TERMUX_PKG_BLACKLISTED_ARCHES="i686"

termux_step_get_source() {
	mkdir -p $TERMUX_PKG_SRCDIR
}

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME

	local _electron_arch=
	if [ $TERMUX_ARCH = "arm" ]; then
		_electron_arch=armv7l
	elif [ $TERMUX_ARCH = "x86_64" ]; then
		_electron_arch=x64
	elif [ $TERMUX_ARCH = "aarch64" ]; then
		_electron_arch=arm64
	else
		termux_error_exit "Unsupported arch: $TERMUX_ARCH"
	fi

	# Download the pre-built electron compiled for Termux
	local _electron_verion="$TERMUX_PKG_VERSION"
	local _electron_archive_url=https://github.com/termux-user-repository/electron-tur-builder/releases/download/v$_electron_verion/electron-v$_electron_verion-linux-$_electron_arch.zip
	local _electron_archive_path="$TERMUX_PKG_CACHEDIR/$(basename $_electron_archive_url)"
	local __sha256sums="
47c6bfbfababd55f8f01b5a22b792dd42d9365a1a47f50b0d94349cc04e82a87 electron-v26.6.10-linux-arm64.zip
b2beae9db7cde6b1fe85b074a218af06f1d9939ad5e63cd6343cf7b2b8406bf6 electron-v26.6.10-linux-armv7l.zip
cde825ac33531beac5dd8fbbc53b8de980d452c3656569fccfbd731989015da1 electron-v26.6.10-linux-x64.zip
	"
	local __checksum
	local __file
	while read -r __checksum __file; do
		if [ "$__checksum" == "" ]; then continue; fi
		if [ "$__file" != "electron-v$_electron_verion-linux-$_electron_arch.zip" ]; then continue; fi
		break
	done <<< "$__sha256sums"
	termux_download $_electron_archive_url $_electron_archive_path $__checksum

	# Unzip the pre-built electron
	unzip $_electron_archive_path -d $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME
}

termux_step_install_license() {
	mkdir -p $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME
	cp $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/LICENSE{,S.chromium.html} $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME/
}
