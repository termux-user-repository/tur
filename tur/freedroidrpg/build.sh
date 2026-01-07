TERMUX_PKG_HOMEPAGE=https://www.freedroid.org/
TERMUX_PKG_DESCRIPTION="A modification of the classical Freedroid engine into an RPG"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@IntinteDAO"
TERMUX_PKG_VERSION=1.0
TERMUX_PKG_SRCURL=https://codeberg.org/freedroid/freedroid-src/archive/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=cbf4bc589014287a955cffaa2467b1ed0cedd6502c83ed92c79545c3fef163e7
TERMUX_PKG_DEPENDS="glew, glu, libglvnd, libjpeg-turbo, libogg, libpng, libvorbis, sdl, sdl-gfx, sdl-image, sdl-mixer, sdl-ttf, zlib"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--with-x"
TERMUX_PKG_GROUPS="games"

termux_step_pre_configure() {
	cd $TERMUX_PKG_SRCDIR
	autoreconf -vfi
}

termux_step_configure() {
	cd $TERMUX_PKG_BUILDDIR

	# Replace potential prefix-based tool paths
	sed -i 's@\${prefix}/bin@/usr/bin@g' $TERMUX_PKG_SRCDIR/configure
	sed -i 's@$prefix/bin@/usr/bin@g' $TERMUX_PKG_SRCDIR/configure

	mkdir -p "$TERMUX_PKG_BUILDDIR/wrappers"
	cat > "$TERMUX_PKG_BUILDDIR/wrappers/sdl-config" << 'EOF'
#!/bin/sh
case "$1" in
	--version) pkg-config --modversion sdl ;;
	--cflags) pkg-config --cflags sdl ;;
	--libs) pkg-config --libs sdl ;;
	--prefix) pkg-config --variable=prefix sdl ;;
	--exec-prefix) pkg-config --variable=exec_prefix sdl ;;
	*)
		echo "Unknown option: $1" >&2
		exit 1
		;;
esac
EOF

	chmod +x "$TERMUX_PKG_BUILDDIR/wrappers/sdl-config"
	export SDL_CONFIG="$TERMUX_PKG_BUILDDIR/wrappers/sdl-config"
	export CPPFLAGS="$CPPFLAGS -DLOCALEDIR=\\\"$TERMUX_PREFIX/share/locale\\\""

	sh $TERMUX_PKG_SRCDIR/configure \
		--prefix=$TERMUX_PREFIX \
		--host=$TERMUX_HOST_PLATFORM \
		--target=$TERMUX_HOST_PLATFORM \
		--with-x \
		SED=sed \
		GREP=grep \
		EGREP=grep \
		FGREP=grep \
		AWK=awk
}

termux_step_post_make_install() {
	# Rename the binary to remove the host prefix
	if [ -f "$TERMUX_PREFIX/bin/${TERMUX_HOST_PLATFORM}-freedroidRPG" ]; then
		mv "$TERMUX_PREFIX/bin/${TERMUX_HOST_PLATFORM}-freedroidRPG" "$TERMUX_PREFIX/bin/freedroidRPG"
	fi

	# Rename the man page to remove the host prefix
	if [ -f "$TERMUX_PREFIX/share/man/man6/${TERMUX_HOST_PLATFORM}-freedroidRPG.6" ]; then
		mv "$TERMUX_PREFIX/share/man/man6/${TERMUX_HOST_PLATFORM}-freedroidRPG.6" "$TERMUX_PREFIX/share/man/man6/freedroidRPG.6"
	fi
}
