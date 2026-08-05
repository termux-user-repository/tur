TERMUX_PKG_HOMEPAGE=https://www.qemu.org
TERMUX_PKG_DESCRIPTION="A generic and open source machine emulator and virtualizer"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="10.2.1"
TERMUX_PKG_SRCURL="https://download.qemu.org/qemu-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=a3717477d8e2c84d630bfffbc20f6cd3293eb45aa1e6dac6d0cc27689991c9e1
TERMUX_PKG_DEPENDS="alsa-lib, dtc, gdk-pixbuf, glib, jack2, gtk3, libbz2, libcairo, libcurl, libdw, libepoxy, libgmp, libgnutls, libiconv, libjpeg-turbo, liblzo, libnettle, libnfs, libpixman, libpng, libslirp, libspice-server, libssh, libusb, libusbredir, libx11, mesa, ncurses, pulseaudio, qemu-common, resolv-conf, sdl2 | sdl2-compat, sdl2-image, virglrenderer, zlib, zstd"
# Required by configuration script, but Leonid Pliushch couldn't find any binary that uses it.
TERMUX_PKG_BUILD_DEPENDS="libtasn1"
TERMUX_PKG_ANTI_BUILD_DEPENDS="sdl2-compat"
TERMUX_SUBPKG_BREAKS="qemu-system-i386-headless, qemu-system-i386"
TERMUX_SUBPKG_REPLACES="qemu-system-i386-headless, qemu-system-i386"
TERMUX_SUBPKG_PROVIDES="qemu-system-i386-headless, qemu-system-i386"
# this package is for 32-bit devices which can't run QEMU version 11 or newer.
TERMUX_PKG_EXCLUDED_ARCHES="x86_64, aarch64"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_configure() {
	termux_setup_ninja

	if [[ "$TERMUX_ARCH" == "i686" ]]; then
		LDFLAGS+=" -latomic"
	fi

	local QEMU_TARGETS=""

	# System emulation.
	QEMU_TARGETS+="arm-softmmu,"
	QEMU_TARGETS+="i386-softmmu,"
	QEMU_TARGETS+="m68k-softmmu,"
	QEMU_TARGETS+="ppc-softmmu,"
	QEMU_TARGETS+="riscv32-softmmu,"

	# User mode emulation.
	QEMU_TARGETS+="arm-linux-user,"
	QEMU_TARGETS+="i386-linux-user,"
	QEMU_TARGETS+="m68k-linux-user,"
	QEMU_TARGETS+="ppc-linux-user,"
	QEMU_TARGETS+="riscv32-linux-user"

	CFLAGS+=" $CPPFLAGS"
	CXXFLAGS+=" $CPPFLAGS"
	LDFLAGS+=" -landroid-shmem -llog"

	# Note: using --disable-stack-protector since stack protector
	# flags already passed by build scripts but we do not want to
	# override them with what QEMU configure provides.
	./configure \
		--prefix="$TERMUX_PREFIX" \
		--cross-prefix="${TERMUX_HOST_PLATFORM}-" \
		--host-cc="gcc" \
		--cc="$CC" \
		--cxx="$CXX" \
		--objcc="$CC" \
		--disable-stack-protector \
		--smbd="$TERMUX_PREFIX/bin/smbd" \
		--enable-coroutine-pool \
		--audio-drv-list=pa,sdl \
		--enable-trace-backends=nop \
		--disable-guest-agent \
		--enable-gnutls \
		--enable-nettle \
		--enable-sdl \
		--enable-sdl-image \
		--enable-gtk \
		--enable-opengl \
		--enable-virglrenderer \
		--disable-vte \
		--enable-curses \
		--enable-iconv \
		--enable-vnc \
		--disable-vnc-sasl \
		--enable-vnc-jpeg \
		--enable-png \
		--disable-xen \
		--disable-xen-pci-passthrough \
		--enable-virtfs \
		--enable-curl \
		--enable-fdt=system \
		--enable-kvm \
		--disable-hvf \
		--disable-whpx \
		--disable-libnfs \
		--enable-lzo \
		--disable-snappy \
		--enable-bzip2 \
		--disable-lzfse \
		--disable-seccomp \
		--enable-libssh \
		--enable-bochs \
		--enable-cloop \
		--enable-dmg \
		--enable-parallels \
		--enable-qed \
		--enable-slirp \
		--enable-spice \
		--enable-libusb \
		--enable-usb-redir \
		--disable-vhost-user \
		--disable-vhost-user-blk-server \
		--target-list="$QEMU_TARGETS"
}

termux_step_post_make_install() {
	local i
	for i in arm i386 m68k ppc riscv32; do
		ln -sfr \
			"${TERMUX_PREFIX}"/share/man/man1/qemu.1 \
			"${TERMUX_PREFIX}"/share/man/man1/qemu-system-${i}.1
	done
}
