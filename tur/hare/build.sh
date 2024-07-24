TERMUX_PKG_HOMEPAGE=https://harelang.org/
TERMUX_PKG_DESCRIPTION="The Hare programming language"
TERMUX_PKG_LICENSE="MPL-2.0"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
_COMMIT=719c97ebc59ed29120c1a033b1f18f89140cf114
_COMMIT_DATE=2023.04.23
TERMUX_PKG_VERSION=${_COMMIT_DATE//./}
TERMUX_PKG_SRCURL=https://git.sr.ht/~sircmpwn/hare/archive/$_COMMIT.tar.gz
TERMUX_PKG_SHA256=c1b0e4792e3ad8171db0b068c4b810f7142ae588e3c09c31fe9a2c9a131778ed
TERMUX_PKG_DEPENDS="harec, qbe"
TERMUX_PKG_BUILD_DEPENDS="scdoc, binutils-cross, harec-cross, qbe-cross"
TERMUX_PKG_SUGGESTS="mime-support"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BLACKLISTED_ARCHES="i686, arm"
TERMUX_PKG_HOSTBUILD=true

TERMUX_PKG_EXTRA_MAKE_ARGS="ARCH=$TERMUX_ARCH"

_CROSS_PREFIX="$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME/cross"

TERMUX_PKG_EXTRA_HOSTBUILD_MAKE_ARGS="
PREFIX=$_CROSS_PREFIX
BINOUT=$TERMUX_PKG_HOSTBUILD_DIR/bin
HARECACHE=$TERMUX_PKG_HOSTBUILD_DIR/cache
AS=as AR=ar CC=cc LD=ld
"

termux_step_host_build() {
	. "$TERMUX_PREFIX/opt/qbe/cross/setup.sh"
	. "$TERMUX_PREFIX/opt/harec/cross/setup.sh"

	cd "$TERMUX_PKG_SRCDIR"
	cp "$TERMUX_PKG_BUILDER_DIR/config.mk" ./config.mk

	arch="$(uname -m)"
	case "$arch" in
		x86_64|amd64)
			host_arch=x86_64
			;;
		aarch64|arm64)
			host_arch=aarch64
			;;
		riscv64)
			host_arch=riscv64
			;;
		*)
			printf "Error: unsupported or unrecognized architecture %s\n" "$arch"
			;;
	esac
	TERMUX_PKG_EXTRA_HOSTBUILD_MAKE_ARGS+=" ARCH=${host_arch}"

	if [ "$TERMUX_ON_DEVICE_BUILD" = false ]; then
		TERMUX_PKG_EXTRA_HOSTBUILD_MAKE_ARGS+="
		AARCH64_AS=$TERMUX_PREFIX/opt/binutils/cross/aarch64-linux-android/bin/as
		RISCV64_AS=$TERMUX_PREFIX/opt/binutils/cross/riscv64-linux-android/bin/as
		X86_64_AS=$TERMUX_PREFIX/opt/binutils/cross/x86-64-linux-android/bin/as
		"
	fi

	make $TERMUX_PKG_EXTRA_HOSTBUILD_MAKE_ARGS -j $TERMUX_PKG_MAKE_PROCESSES
	make install $TERMUX_PKG_EXTRA_HOSTBUILD_MAKE_ARGS
	cp "$TERMUX_PKG_BUILDER_DIR/cross_setup.sh" "$_CROSS_PREFIX/setup.sh"
}

termux_step_configure() {
	# Remove this marker all the time.
	rm -rf $TERMUX_HOSTBUILD_MARKER

	case "$TERMUX_ARCH" in
		x86_64)
			QBE_TARGET=amd64_sysv
			tools_overwrite="X86_64"
			;;
		aarch64)
			QBE_TARGET=arm64
			tools_overwrite="AARCH64"
			;;
		riscv64)
			QBE_TARGET=rv64
			tools_overwrite="RISCV64"
			;;
		*)
			printf "Error: unsupported or unrecognized architecture %s\n" "$TERMUX_ARCH"
			;;
	esac

	TERMUX_PKG_EXTRA_MAKE_ARGS+="
	${tools_overwrite}_AS=as
	${tools_overwrite}_AR=ar
	${tools_overwrite}_CC=cc
	${tools_overwrite}_LD=ld
	"

	if [ "$TERMUX_ON_DEVICE_BUILD" = false ]; then
		TERMUX_PKG_EXTRA_MAKE_ARGS+="
		HOST_HARE=$_CROSS_PREFIX/bin/hare
		AS=$TERMUX_PREFIX/opt/binutils/cross/$TERMUX_HOST_PLATFORM/bin/as
		"
	fi

	export QBEFLAGS="-t $QBE_TARGET"
	export HAREBUILDFLAGS="-t $TERMUX_ARCH"
	## -a flag is not yet working
	# export HAREFLAGS="-a $TERMUX_ARCH"
}
