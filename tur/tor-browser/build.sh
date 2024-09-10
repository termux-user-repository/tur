TERMUX_PKG_HOMEPAGE=https://www.torproject.org/
TERMUX_PKG_DESCRIPTION="Tor Browser Bundle: anonymous browsing using Firefox and Tor"
TERMUX_PKG_LICENSE="MPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="128.2.0esr-14.0-1-build3"
TERMUX_PKG_SRCURL=git+https://gitlab.torproject.org/tpo/applications/tor-browser
# ffmpeg and pulseaudio are dependencies through dlopen(3):
TERMUX_PKG_DEPENDS="ffmpeg, fontconfig, freetype, gdk-pixbuf, glib, gtk3, libandroid-shmem, libandroid-spawn, libc++, libcairo, libevent, libffi, libice, libicu, libjpeg-turbo, libnspr, libnss, libpixman, libsm, libvpx, libwebp, libx11, libxcb, libxcomposite, libxdamage, libxext, libxfixes, libxrandr, libxtst, pango, pulseaudio, tor, zlib"
TERMUX_PKG_BUILD_DEPENDS="libcpufeatures, libice, libsm"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_GIT_BRANCH="tor-browser-$TERMUX_PKG_VERSION"
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"

termux_step_post_get_source() {
	local f="media/ffvpx/config_unix_aarch64.h"
	echo "Applying sed substitution to ${f}"
	sed -E '/^#define (CONFIG_LINUX_PERF|HAVE_SYSCTL) /s/1$/0/' -i ${f}
}

termux_step_pre_configure() {
	# XXX: flang toolchain provides libclang.so
	termux_setup_flang
	local __fc_dir="$(dirname $(command -v $FC))"
	local __flang_toolchain_folder="$(realpath "$__fc_dir"/..)"
	if [ ! -d "$TERMUX_PKG_TMPDIR/firefox-toolchain" ]; then
		rm -rf "$TERMUX_PKG_TMPDIR"/firefox-toolchain-tmp
		mv "$__flang_toolchain_folder" "$TERMUX_PKG_TMPDIR"/firefox-toolchain-tmp

		cp "$(command -v "$CC")" "$TERMUX_PKG_TMPDIR"/firefox-toolchain-tmp/bin/
		cp "$(command -v "$CXX")" "$TERMUX_PKG_TMPDIR"/firefox-toolchain-tmp/bin/
		cp "$(command -v "$CPP")" "$TERMUX_PKG_TMPDIR"/firefox-toolchain-tmp/bin/

		mv "$TERMUX_PKG_TMPDIR"/firefox-toolchain-tmp "$TERMUX_PKG_TMPDIR"/firefox-toolchain
	fi
	export PATH="$TERMUX_PKG_TMPDIR/firefox-toolchain/bin:$PATH"

	termux_setup_nodejs
	termux_setup_rust

	# https://github.com/rust-lang/rust/issues/49853
	# https://github.com/rust-lang/rust/issues/45854
	# Out of memory when building gkrust
	# CI shows (signal: 9, SIGKILL: kill)
	if [ "$TERMUX_DEBUG_BUILD" = false ]; then
		case "${TERMUX_ARCH}" in
		aarch64|arm|i686|x86_64) RUSTFLAGS+=" -C debuginfo=1" ;;
		esac
	fi

	cargo install cbindgen

	export HOST_CC=$(command -v clang)
	export HOST_CXX=$(command -v clang++)

	export BINDGEN_CFLAGS="--target=$CCTERMUX_HOST_PLATFORM --sysroot=$TERMUX_PKG_TMPDIR/firefox-toolchain/sysroot"
	local env_name=BINDGEN_EXTRA_CLANG_ARGS_${CARGO_TARGET_NAME@U}
	env_name=${env_name//-/_}
	export $env_name="$BINDGEN_CFLAGS"

	# https://reviews.llvm.org/D141184
	CXXFLAGS+=" -U__ANDROID__ -D_LIBCPP_HAS_NO_C11_ALIGNED_ALLOC"
	LDFLAGS+=" -landroid-shmem -landroid-spawn -llog"

	if [ "$TERMUX_ARCH" = "arm" ]; then
		# For symbol android_getCpuFeatures
		LDFLAGS+=" -l:libndk_compat.a"
	fi
}

termux_step_configure() {
	if [ "$TERMUX_CONTINUE_BUILD" == "true" ]; then
		termux_step_pre_configure
		cd $TERMUX_PKG_SRCDIR
	fi

	sed \
		-e "s|@TERMUX_HOST_PLATFORM@|${TERMUX_HOST_PLATFORM}|" \
		-e "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|" \
		-e "s|@CARGO_TARGET_NAME@|${CARGO_TARGET_NAME}|" \
		$TERMUX_PKG_BUILDER_DIR/mozconfig.cfg > .mozconfig

	if [ "$TERMUX_DEBUG_BUILD" = true ]; then
		cat >>.mozconfig - <<END
ac_add_options --enable-debug-symbols
ac_add_options --disable-install-strip
END
	fi

	./mach configure
}

termux_step_make() {
	./mach build
	./mach buildsymbols
}

termux_step_make_install() {
	./mach install

	install -Dm644 -t "${TERMUX_PREFIX}/share/applications" "${TERMUX_PKG_BUILDER_DIR}/tor-browser.desktop"
}

termux_step_post_make_install() {
	# https://github.com/termux/termux-packages/issues/18429
	# https://phabricator.services.mozilla.com/D181687
	# Android 8.x and older not support "-z pack-relative-relocs" / DT_RELR
	local r=$("${READELF}" -d "${TERMUX_PREFIX}/bin/tor-browser")
	if [[ -n "$(echo "${r}" | grep "(RELR)")" ]]; then
		termux_error_exit "DT_RELR is unsupported on Android 8.x and older\n${r}"
	fi
}
