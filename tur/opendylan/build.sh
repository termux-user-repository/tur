TERMUX_PKG_HOMEPAGE=https://opendylan.org
TERMUX_PKG_DESCRIPTION="Open Dylan is a compiler and a set of libraries for the Dylan programming language."
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="License.txt"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2024.1.0
TERMUX_PKG_SRCURL=git+https://github.com/dylan-lang/opendylan
TERMUX_PKG_DEPENDS="libgc"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-gc=${TERMUX_PREFIX}
--with-harp-collector=boehm
"

termux_step_pre_configure() {
	curl -Lo "${TERMUX_PKG_CACHEDIR}/opendylan.tar.bz2" https://github.com/dylan-lang/opendylan/releases/download/v2024.1.0/opendylan-2024.1-x86_64-linux.tar.bz2
	tar -xf "${TERMUX_PKG_CACHEDIR}/opendylan.tar.bz2" -C "${TERMUX_PKG_CACHEDIR}"
	export PATH="$PATH:${TERMUX_PKG_CACHEDIR}/opendylan-2024.1/bin"

	find "${TERMUX_PKG_CACHEDIR}/opendylan-2024.1" -name '*.jam' -type f -exec \
		sed -i \
		-e 's/-lrt//g' \
		-e 's/-lpthread//g' \
		{} \;

	case "${TARGET_ARCH:=${TERMUX_ARCH}}" in
	i686) TARGET_ARCH=x86 ;;
	esac
	export OPEN_DYLAN_TARGET_PLATFORM="${TARGET_ARCH}-linux"

	CFLAGS+=" -Wno-error=int-conversion -femulated-tls"
	LDFLAGS+=" -Wl,-plugin-opt=-emulated-tls=1"

	sed -i \
		-e "s|@CC@|${CC}|g" \
		-e "s|@CFLAGS@|${CPPFLAGS} ${CFLAGS}|g" \
		-e "s|@LDFLAGS@|${LDFLAGS}|g" \
		-e "s|@ARCH@|${TARGET_ARCH}|g" \
		"${TERMUX_PKG_SRCDIR}/android-build.jam"

	./autogen.sh
}

termux_step_make() {
	make -j "${TERMUX_PKG_MAKE_PROCESSES}" -C "sources/lib/run-time" clean install \
		CC="${CC} ${CFLAGS}" \
		OPEN_DYLAN_TARGET_PLATFORM="${OPEN_DYLAN_TARGET_PLATFORM}" \
		OPEN_DYLAN_USER_INSTALL="${TERMUX_PREFIX}"

	dylan-compiler \
		-jobs "${TERMUX_PKG_MAKE_PROCESSES}" \
		-back-end c \
		-build-script "${TERMUX_PKG_SRCDIR}/android-build.jam" \
		-release \
		-verbose \
		-echo-input \
		-build sources/environment/console/dylan-compiler.lid

	find ./_build
}
