TERMUX_PKG_HOMEPAGE=https://www.chromium.org/Home
TERMUX_PKG_DESCRIPTION="Chromium web browser"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="Chongyun Lee <uchkks@protonmail.com>"
TERMUX_PKG_VERSION=130.0.6723.116
TERMUX_PKG_SRCURL=https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=968799e41158fdcc85af6f5547d3dd4730d6e51219e43aa2f1ab6ab5e00582ba
TERMUX_PKG_DEPENDS="atk, cups, dbus, fontconfig, gtk3, krb5, libc++, libdrm, libevdev, libxkbcommon, libminizip, libnss, libwayland, libx11, mesa, openssl, pango, pulseaudio, zlib"
# TODO: Split chromium-common and chromium-headless
# TERMUX_PKG_DEPENDS+=", chromium-common"
# TERMUX_PKG_SUGGESTS="chromium-headless, chromium-driver"
TERMUX_PKG_SUGGESTS="qt5-qtbase"
TERMUX_PKG_BUILD_DEPENDS="qt5-qtbase, qt5-qtbase-cross-tools"
TERMUX_PKG_ANTI_BUILD_DEPENDS="atk, cups, dbus, fontconfig, gtk3, krb5, libc++, libdrm, libevdev, libxkbcommon, libminizip, libnss, libwayland, libx11, mesa, openssl, pango, pulseaudio, zlib, qt5-qtbase, qt5-qtbase-cross-tools"
TERMUX_PKG_AUTO_UPDATE=true
# Chromium doesn't support i686 on Linux.
TERMUX_PKG_BLACKLISTED_ARCHES="i686"

termux_pkg_auto_update() {
	local latest_version="$(curl -s 'https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Linux&num=10&offset=0' | jq -rc '.[].version' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | tail -n 1)"
	if ! termux_pkg_is_update_needed \
		"${TERMUX_PKG_VERSION#*:}" "${latest_version}"; then
		echo "INFO: No update needed. Already at version '${latest_version}'."
		return 0
	fi
	termux_error_exit "ERROR: current version '${TERMUX_PKG_VERSION#*:}', latest version '${latest_version}'."
}

termux_step_configure() {
	:
}

termux_step_make() {
	:
}

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME

	local __sha256sums="
56d2cbf3d7ce21b1309f58b329dfa39a91bebcdbe3e7744e55ec3d2b2e6cca73 chromium-v130.0.6723.116-linux-aarch64.zip
a0c58325dba2d34a4c43b045b99014d95eed976b7a41857284f0897bba3972f1 chromium-v130.0.6723.116-linux-arm.zip
9b7c7ca0ea06b376aa06253c85fb909d4f0f9040a98daef7fd097065fd40e837 chromium-v130.0.6723.116-linux-x86_64.zip
	"
	local __checksum
	local __file
	while read -r __checksum __file; do
		if [ "$__checksum" == "" ]; then continue; fi
		if [ "$__file" != "chromium-v$TERMUX_PKG_VERSION-linux-$TERMUX_ARCH.zip" ]; then continue; fi
		break
	done <<< "$__sha256sums"

	# Download the pre-built chromium compiled for Termux
	local _chromium_version="$TERMUX_PKG_VERSION"
	local _chromium_archive_url=https://github.com/termux-user-repository/chromium-builder/releases/download/$_chromium_version/$__file
	local _chromium_archive_path="$TERMUX_PKG_CACHEDIR/$(basename $_chromium_archive_url)"
	termux_download $_chromium_archive_url $_chromium_archive_path $__checksum

	# Unzip the pre-built chromium
	unzip $_chromium_archive_path -d $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME

	# Install binary to $PREFIX/bin
	ln -sfr $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/chromium-launcher.sh $TERMUX_PREFIX/bin/chromium-browser
	ln -sfr $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/chromedriver $TERMUX_PREFIX/bin/
	ln -sfr $TERMUX_PREFIX/lib/$TERMUX_PKG_NAME/headless_shell $TERMUX_PREFIX/bin/

	# Install man pages and desktop files
	install -Dm644 $TERMUX_PKG_SRCDIR/chrome/app/resources/manpage.1.in \
		"$TERMUX_PREFIX/share/man/man1/chromium.1"
	install -Dm644 $TERMUX_PKG_SRCDIR/chrome/installer/linux/common/desktop.template \
		"$TERMUX_PREFIX/share/applications/chromium.desktop"
	sed -i \
		-e 's/@@MENUNAME@@/Chromium/g' \
		-e 's/@@PACKAGE@@/chromium/g' \
		-e 's/@@USR_BIN_SYMLINK_NAME@@/chromium-browser/g' \
		-e "s|Exec=/usr/bin|Exec=$TERMUX_PREFIX/bin|g" \
		"$TERMUX_PREFIX/share/applications/chromium.desktop" \
		"$TERMUX_PREFIX/share/man/man1/chromium.1"

	# Install logos
	for size in 24 48 64 128 256; do
		install -Dm644 "$TERMUX_PKG_SRCDIR/chrome/app/theme/chromium/product_logo_$size.png" \
			"$TERMUX_PREFIX/share/icons/hicolor/${size}x${size}/apps/chromium.png"
	done

	for size in 16 32; do
		install -Dm644 "$TERMUX_PKG_SRCDIR/chrome/app/theme/default_100_percent/chromium/product_logo_$size.png" \
			"$TERMUX_PREFIX/share/icons/hicolor/${size}x${size}/apps/chromium.png"
	done

	# Install AppStream metadata file
	install -Dm644 $TERMUX_PKG_SRCDIR/chrome/installer/linux/common/chromium-browser/chromium-browser.appdata.xml \
		"$TERMUX_PREFIX/share/metainfo/chromium.appdata.xml"
	sed -ni \
		-e 's/chromium-browser\.desktop/chromium.desktop/' \
		-e '/<update_contact>/d' \
		-e '/<p>/N;/<p>\n.*\(We invite\|Chromium supports Vorbis\)/,/<\/p>/d' \
		-e '/^<?xml/,$p' \
		"$TERMUX_PREFIX/share/metainfo/chromium.appdata.xml"
}

# TODO:
# (2) Split packages

# ######################### About system libraries ############################
# We only pick up a few libraries to let chromium link against. Others may
# contain linking error due to the version mismatch between Google-provided
# sysroot and Termux.
# Name in Chromium | libdrm fontconfig
# Name in Termux   | libdrm fontconfig
#
# #############################################################################

# ######################### About Native Client ###############################
# When set `enable_nacl = true`, the following error occurs.
# ninja: error: 'native_client/toolchain/linux_x86/pnacl_newlib/bin/arm-nacl-objcopy', needed by 'nacl_irt_arm.nexe', missing and no known rule to make it.
# If we want to enable NaCl, maybe we should build the toolchain of NaCl too.
# But I don't think this is necessary. NaCl existing or not will take little
# influence on Chromium. So I'd like to disable NaCl.
# #############################################################################

# ############################ About Sandbox ##################################
# First, setuid-sandbox is never usable on Termux, beacuse setuid syscall is
# disabled by Android's SELinux. Second, lots of patches are needed to let
# seccomp-bpf sandbox work properly on Android. I've tried many times but I
# can't make it. If your are willing to work on this, feel free to submit a PR.
# #############################################################################
