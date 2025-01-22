TERMUX_PKG_HOMEPAGE=https://www.enlightenment.org
TERMUX_PKG_DESCRIPTION="The Enlightenment Foundation Libraries (EFL) is a stack of libraries providing a wide degree of functionality. Originally written to support development of the Enlightenment window manager, the libraries have increasingly been used in embedded systems."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=1.28.0
TERMUX_PKG_SRCURL="https://download.enlightenment.org/rel/libs/efl/efl-$TERMUX_PKG_VERSION.tar.xz"
TERMUX_PKG_SHA256="f09a43d6b4861be06cc0e2849c53296413d4e52c8e31f52fc95e9ea5f1c59a36"
TERMUX_PKG_DEPENDS="libjpeg-turbo, libluajit, dbus, libsndfile, pulseaudio, libxcomposite, libxdamage, libxinerama, libxtst, libxcursor, libtiff, giflib, libwebp, openjpeg, fribidi, harfbuzz, lua52, poppler, libspectre, libraw, librsvg, libxi, libandroid-shmem, gstreamer, bison, gst-plugins-base, libwayland-protocols, libxrandr, libxkbcommon"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-Deeze=false -Dsystemd=false -Dinput=false -Dwl=true -Decore-imf-loaders-disabler=['ibus','scim']"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_RM_AFTER_INSTALL="
lib/python3.12/__pycache__/cProfile.cpython-312.pyc
lib/python3.12/__pycache__/profile.cpython-312.pyc
lib/python3.12/__pycache__/tarfile.cpython-312.pyc
"

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "This package doesn't support cross-compiling."
	fi
}

termux_step_configure() {
	termux_setup_meson
	$TERMUX_MESON build --prefix $TERMUX_PREFIX $TERMUX_PKG_EXTRA_CONFIGURE_ARGS
}

termux_step_make() {
	termux_setup_ninja
	cd build
	ninja \
	-j ${TERMUX_PKG_MAKE_PROCESSES} \
	install
}
