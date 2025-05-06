
TERMUX_PKG_DESCRIPTION="load linked drivers from a different folder fe  vulkan.ums9230.so -> ../egl/libGLES_mali.so"
TERMUX_PKG_VERSION=0
TERMUX_PKG_LICENSE="WTFPL"
TERMUX_PKG_SRCURL=(
# git+$HOME/libhardware
# git+$HOME/core
# git+$HOME/logging
git+https://github.com/john-peterson/platform_hardware_libhardware
git+https://android.googlesource.com/platform/system/core
git+https://android.googlesource.com/platform/system/logging
)
TERMUX_PKG_GIT_BRANCH=(mali main main)
# TERMUX_PKG_BUILD_DEPENDS="bionic-host"

termux_step_get_source() { 
	# /cache
	# I have to do everything myself apparently 
	set +e
	j=0
	for i in "${TERMUX_PKG_SRCURL[@]}"; do
			url=${i:4}
			branch=${TERMUX_PKG_GIT_BRANCH[j]}
			# test -z "$i" && target=.
			git clone -q --branch $branch --depth 5 $url
			((j++))
	done
	mkdir $TERMUX_PKG_SRCDIR
	cp -r * $TERMUX_PKG_SRCDIR/
	# TERMUX_PKG_SRCDIR=$TERMUX_PKG_SRCDIR/$(basename ${TERMUX_PKG_SRCURL[0]})
	# exit; 
}

termux_step_host_build() {
	# Can someone fix all these bugs
	if ! $TERMUX_ON_DEVICE_BUILD;then
		source $TERMUX_SCRIPTDIR/script/termux_step_host_build.sh
		termux_step_host_build
	fi
	}

termux_step_setup_toolchain() {
	# God knows what this is doing 
	if $TERMUX_ON_DEVICE_BUILD;then
		READELF=readelf
		STRIP=strip
	else
		source $TERMUX_SCRIPTDIR/script/termux_step_setup_toolchain
termux_step_setup_toolchain
	fi
}

termux_step_configure() { :; }
termux_step_make() { 
	# /build
	if ! $TERMUX_ON_DEVICE_BUILD;then
		echo trying to link with libvndksupport.so off device will fail  Can you run this on device instead and upload the packet much appreciated 
	fi

cd $TERMUX_PKG_SRCDIR

clang *libhardware/hardware.c -g -I *libhardware/include -I core/include -I core/libvndksupport/include -I logging/liblog/include  -shared -l cutils -l vndksupport -l log -o $TERMUX_PKG_BUILDDIR/libhardware.so
}

termux_step_make_install() {
	mkdir -p $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib
	cp $TERMUX_PKG_BUILDDIR/* $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib/
}

termux_step_install_license(){
	# this thing is completely broken 
	:;
}

termux_step_extract_into_massagedir() {
	# this is trying to tar my entire system
	:;
}

# termux_step_post_massage() { :; }


