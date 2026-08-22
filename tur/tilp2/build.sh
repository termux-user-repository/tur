TERMUX_PKG_HOMEPAGE="http://lpg.ticalc.org/prj_tilp/"
TERMUX_PKG_DESCRIPTION="TiLP is a linking program for Texas Instruments' graphing calculators."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="3ls-it <3ls-it@pm.me>"
TERMUX_PKG_VERSION=1.18
# No version number in the tarball; this is the cannonical source
TERMUX_PKG_SRCURL="https://www.ticalc.org/pub/unix/tilp.tar.gz"
TERMUX_PKG_SHA256=6ba834f7fdbbce9818ccaa864222aed2d1688b210e9ff2c59576d1fde5159cd7
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="gettext, glib, gtk2, libticables2, libticalcs2, libticonv, libtifiles2, libusb0, termux-api, zlib"
TERMUX_PKG_SUGGESTS="ti-utils"

termux_step_pre_configure() {
		autoreconf -fi
}

termux_step_post_make_install() {
		# We rename the binary as it needs a `termux-usb` wrapper
		mv "$TERMUX_PREFIX/bin/tilp" "$TERMUX_PREFIX/bin/tilp.real"

		# Install the wrapper script as `tilp`
		install -Dm700 \
				"$TERMUX_PKG_BUILDER_DIR/tilp" \
				"$TERMUX_PREFIX/bin/tilp"
}

termux_step_create_debscripts() {
		cat <<-EOF > ./postinst
						#!$TERMUX_PREFIX/bin/sh
						echo
						echo "********"
						echo "TiLP2 is now installed."
						echo
						echo "You will need to install the Termux:API app since the"
						echo "launcher, 'tilp', uses 'termux-usb' as a wrapper to"
						echo "give TiLP USB access to the GraphLink (SilverLink)"
						echo "device/cable."
						echo
						echo "Known Limitations"
						echo
						echo "Currently there are two known limitations of this revision:"
						echo "- ROM dumps create an unusable file,"
						echo "- TiLP cannot connect with a TiEmu emulated device."
						echo
						echo "********"
						echo
		EOF
}
