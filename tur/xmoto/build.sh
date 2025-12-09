TERMUX_PKG_HOMEPAGE=https://xmoto.tuxfamily.org/
TERMUX_PKG_DESCRIPTION="A challenging 2D motocross platform game"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.6.3"
TERMUX_PKG_SRCURL=https://github.com/xmoto/xmoto/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=64cb29934660456ec82cebdaa0d3d273a862e10760e8ee80443928d317242484
TERMUX_PKG_DEPENDS="libx11, libjpeg-turbo, libpng, lua54, sdl2 | sdl2-compat, sdl2-mixer, sdl2-net, libcurl, bzip2, libxdg-basedir, sdl2-ttf, glu, game-music-emu, libwavpack"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_HOSTBUILD=true

# Function to obtain the .deb URL
obtain_deb_url() {
	local url attempt retries wait PAGE deb_url
	url="https://packages.ubuntu.com/noble/amd64/$1/download"
	retries=50
	wait=50
	>&2 echo "url: $url"
	for ((attempt=1; attempt<=retries; attempt++)); do
		PAGE="$(curl -s "$url")"
		deb_url="$(grep -oE 'https?://.*\.deb' <<< "$PAGE" | head -n1)"
		if [[ -n "$deb_url" ]]; then
			echo "$deb_url"
			return 0
		else
			>&2 echo "Attempt $attempt: Failed to obtain deb URL. Retrying in $wait seconds..."
		fi
		sleep "$wait"
	done
	termux_error_exit "Failed to obtain URL after $retries attempts."
}

_install_ubuntu_packages() {
	# install Ubuntu packages, like in the aosp-libs build.sh
	export HOSTBUILD_ROOTFS="${TERMUX_PKG_HOSTBUILD_DIR}/ubuntu_packages"
	mkdir -p "${HOSTBUILD_ROOTFS}"
	local URL DEB_NAME DEB_LIST
	DEB_LIST="$@"

	for i in $DEB_LIST; do
		echo "deb: $i"
		URL="$(obtain_deb_url "$i")"
		DEB_NAME="${URL##*/}"
		termux_download "$URL" "${TERMUX_PKG_CACHEDIR}/${DEB_NAME}" SKIP_CHECKSUM
		mkdir -p "${TERMUX_PKG_TMPDIR}/${DEB_NAME}"
		ar x "${TERMUX_PKG_CACHEDIR}/${DEB_NAME}" --output="${TERMUX_PKG_TMPDIR}/${DEB_NAME}"
		tar xf "${TERMUX_PKG_TMPDIR}/${DEB_NAME}"/data.tar.* \
		-C "${HOSTBUILD_ROOTFS}"
	done
}

load_ubuntu_packages() {
	export HOSTBUILD_ROOTFS="${TERMUX_PKG_HOSTBUILD_DIR}/ubuntu_packages"
	export LD_LIBRARY_PATH="${HOSTBUILD_ROOTFS}/usr/lib/x86_64-linux-gnu"
	LD_LIBRARY_PATH+=":${HOSTBUILD_ROOTFS}/usr/lib"
	LD_LIBRARY_PATH+=":${HOSTBUILD_ROOTFS}/usr/lib/x86_64-linux-gnu/pulseaudio"
	export PATH="${HOSTBUILD_ROOTFS}/usr/games:$PATH"
}

termux_step_host_build() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "true" ]]; then
		return
	fi

	_install_ubuntu_packages \
		fonts-arphic-bkai00mp \
		fonts-dejavu-core \
		fonts-dejavu-mono \
		libasyncns0 \
		libccd2 \
		libchipmunk7 \
		libdecor-0-0 \
		libdecor-0-plugin-1-gtk \
		libflac12t64 \
		libfluidsynth3 \
		libinstpatch-1.0-2 \
		libjack-jackd2-0 \
		libmodplug1 \
		libmp3lame0 \
		libmpg123-0t64 \
		libode8t64 \
		libogg0 \
		libopus0 \
		libopusfile0 \
		libpipewire-0.3-0t64 \
		libpipewire-0.3-common \
		libpulse0 \
		libsamplerate0 \
		libsdl2-2.0-0 \
		libsdl2-mixer-2.0-0 \
		libsdl2-net-2.0-0 \
		libsdl2-ttf-2.0-0 \
		libsndfile1 \
		libspa-0.2-modules \
		libvorbis0a \
		libvorbisenc2 \
		libvorbisfile3 \
		libwebrtc-audio-processing1 \
		libxdg-basedir1 \
		libxss1 \
		timgm6mb-soundfont \
		xmoto \
		xmoto-data
}

termux_step_pre_configure() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		load_ubuntu_packages
	fi
}
