TERMUX_PKG_HOMEPAGE=https://research.deezer.com/projects/spleeter.html
TERMUX_PKG_DESCRIPTION="Audio source separation based, pacakged in proot"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2.4.0
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_DEPENDS="proot-distro"
TERMUX_PKG_BUILD_DEPENDS="wget"
TERMUX_PKG_UNDEF_SYMBOLS_FILES=all

TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
}

termux_step_post_get_source () {
	cp "$TERMUX_PKG_BUILDER_DIR"/LICENSE "$TERMUX_PKG_SRCDIR"/
}

proot_run () {
	proot-distro login app_spleeter --isolated -- "$@"
}
proot_run_user () {
	proot-distro login app_spleeter --user android --isolated -- "$@"
}

termux_step_make_install(){
	# install 2stems model
	mkdir -p "$PREFIX/etc/spleeter-proot/pretrained_models/2stems"
	wget "https://github.com/deezer/spleeter/releases/download/v1.4.0/2stems.tar.gz"
	tar -xf 2stems.tar.gz -C "$PREFIX/etc/spleeter-proot/pretrained_models/2stems/"

	# install proot rootfs and spleeter
	proot-distro install --override-alias app_spleeter ubuntu

	proot_run apt update
	proot_run apt upgrade -y
	proot_run apt install -y libhdf5-dev gcc wget pkg-config
	proot_run useradd -U -m -s /bin/bash -p root android
	proot_run_user mkdir -p /home/android/miniconda3
	proot_run_user wget https://repo.anaconda.com/miniconda/Miniconda3-py310_24.4.0-0-Linux-$TERMUX_ARCH.sh -O /home/android/miniconda3/miniconda.sh
	proot_run_user bash /home/android/miniconda3/miniconda.sh -b -u -p /home/android/miniconda3
	proot_run_user rm -rf /home/android/miniconda3/miniconda.sh
	proot_run_user /home/android/miniconda3/bin/conda config --set auto_activate_base false
	proot_run_user /home/android/miniconda3/bin/conda create -n spleeter_py310 -y python=3.10
	proot_run_user /home/android/miniconda3/bin/conda run -n spleeter_py310 pip install ffmpeg-python httpx[http2]==0.19.0 norbert typer==0.3.2
	proot_run_user /home/android/miniconda3/bin/conda run -n spleeter_py310 pip install pandas==1.5.3 tensorflow==2.10
	proot_run_user /home/android/miniconda3/bin/conda run -n spleeter_py310 pip install --no-deps spleeter
	proot_run_user /home/android/miniconda3/bin/conda run -n spleeter_py310 pip cache purge
	proot_run apt autoremove -y gcc wget pkg-config

	install -Dm700 "$TERMUX_PKG_BUILDER_DIR"/spleeter-proot $TERMUX_PREFIX/bin/
	ln -sfr $TERMUX_PREFIX/bin/spleeter-proot $TERMUX_PREFIX/bin/spleeter
}
