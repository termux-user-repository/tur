TERMUX_PKG_HOMEPAGE=https://ffmpeg.org
TERMUX_PKG_DESCRIPTION="Tools and libraries to manipulate a wide range of multimedia formats and protocols"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=7.0.2
TERMUX_PKG_SRCURL=https://www.ffmpeg.org/releases/ffmpeg-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=8646515b638a3ad303e23af6a3587734447cb8fc0a0c064ecdb8e95c4fd8b389
TERMUX_PKG_DEPENDS="freetype, game-music-emu, libaom, libandroid-glob, libass, libbluray, libbz2, libdav1d, libgnutls, libiconv, liblzma, libmp3lame, libopus, librav1e, libsoxr, libtheora, libvorbis, libvpx, libvidstab, libwebp, libx264, libx265, libxml2, xvidcore, zlib"

termux_step_configure() {
	cd $TERMUX_PKG_BUILDDIR

	_RPATH_FLAG="-Wl,-rpath=$TERMUX_PREFIX/lib"
	_RPATH_FLAG_ADD="-Wl,-rpath=$TERMUX_PREFIX/opt/ffmpeg7/lib"
	LDFLAGS="${LDFLAGS/$_RPATH_FLAG/$_RPATH_FLAG_ADD $_RPATH_FLAG}"

	local _EXTRA_CONFIGURE_FLAGS=""
	if [ $TERMUX_ARCH = "arm" ]; then
		_ARCH="armeabi-v7a"
		_EXTRA_CONFIGURE_FLAGS="--enable-neon"
	elif [ $TERMUX_ARCH = "i686" ]; then
		_ARCH="x86"
		# Specify --disable-asm to prevent text relocations on i686,
		# see https://trac.ffmpeg.org/ticket/4928
		_EXTRA_CONFIGURE_FLAGS="--disable-asm"
	elif [ $TERMUX_ARCH = "x86_64" ]; then
		_ARCH="x86_64"
	elif [ $TERMUX_ARCH = "aarch64" ]; then
		_ARCH=$TERMUX_ARCH
		_EXTRA_CONFIGURE_FLAGS="--enable-neon"
	else
		termux_error_exit "Unsupported arch: $TERMUX_ARCH"
	fi

	$TERMUX_PKG_SRCDIR/configure \
		--prefix="$TERMUX_PREFIX/opt/ffmpeg7" \
		--arch="${_ARCH}" \
		--as="$AS" \
		--cc="$CC" \
		--cxx="$CXX" \
		--nm="$NM" \
		--pkg-config="$PKG_CONFIG" \
		--strip="$STRIP" \
		--cross-prefix="${TERMUX_HOST_PLATFORM}-" \
		--disable-indevs \
		--disable-outdevs \
		--enable-indev=lavfi \
		--disable-static \
		--disable-symver \
		--enable-cross-compile \
		--enable-gnutls \
		--enable-gpl \
		--enable-libaom \
		--enable-libass \
		--enable-libbluray \
		--enable-libdav1d \
		--enable-libgme \
		--enable-libmp3lame \
		--enable-libfreetype \
		--enable-libvorbis \
		--enable-libopus \
		--enable-librav1e \
		--enable-libsoxr \
		--enable-libx264 \
		--enable-libx265 \
		--enable-libxvid \
		--enable-libvidstab \
		--enable-libvpx \
		--enable-libwebp \
		--enable-libxml2 \
		--enable-libtheora \
		--enable-shared \
		--target-os=android \
		--extra-libs="-landroid-glob" \
		--disable-vulkan \
		$_EXTRA_CONFIGURE_FLAGS
}

termux_step_post_make_install() {
	# Symlink binaries to $PREFIX/bin with version suffix
	mkdir -p $TERMUX_PREFIX/bin
	local f
	for f in $TERMUX_PREFIX/opt/ffmpeg7/bin/*; do
		ln -sfr $f $TERMUX_PREFIX/bin/"$(basename $f)"7
	done
}
