TERMUX_PKG_HOMEPAGE=https://www.rust-lang.org/
TERMUX_PKG_DESCRIPTION="Rust compiler and utilities (nightly version)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.89.0-2025.06.02-nightly"
_RUST_VERSION=$(echo $TERMUX_PKG_VERSION | cut -d- -f1)
_DATE="$(echo $TERMUX_PKG_VERSION | cut -d- -f2 | sed 's|\.|-|g')"
_LLVM_MAJOR_VERSION=$(. $TERMUX_SCRIPTDIR/packages/libllvm/build.sh; echo $LLVM_MAJOR_VERSION)
_LLVM_MAJOR_VERSION_NEXT=$((_LLVM_MAJOR_VERSION + 1))
_LZMA_VERSION=$(. $TERMUX_SCRIPTDIR/packages/liblzma/build.sh; echo $TERMUX_PKG_VERSION)
TERMUX_PKG_SRCURL=https://static.rust-lang.org/dist/$_DATE/rustc-nightly-src.tar.xz
TERMUX_PKG_SHA256=f1524037c61866ff33abdf0493894ffd10f64eb2f083233f42d4d6b154d0c593
TERMUX_PKG_DEPENDS="clang, libandroid-execinfo, libc++, libllvm (<< ${_LLVM_MAJOR_VERSION_NEXT}), lld, openssl, zlib"
TERMUX_PKG_BUILD_DEPENDS="wasi-libc"
TERMUX_PKG_NO_REPLACE_GUESS_SCRIPTS=true
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_RM_AFTER_INSTALL="
bin/llc
bin/lld
bin/llvm-*
bin/opt
bin/sh
lib/liblzma.a
lib/liblzma.so
lib/liblzma.so.${_LZMA_VERSION}
lib/libtinfo.so.6
lib/libz.so
lib/libz.so.1
share/wasi-sysroot
"

__sudo() {
	env -i PATH="$PATH" sudo "$@"
}

termux_pkg_auto_update() {
	# Setup rust-nightly toolchain
	curl https://sh.rustup.rs -sSfo /tmp/rustup.sh
	sh /tmp/rustup.sh -y --default-toolchain none
	rustup install nightly
	export PATH="$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin:$PATH"

	# Get latest nightly version from rustc
	local latest_nightly_version="$(rustc --version | cut -d' ' -f2 | cut -d- -f1)"
	local latest_nightly_date="$(rustc --version | cut -d' ' -f4 | cut -d')' -f1)"
	latest_nightly_date="$(date +%Y-%m-%d -d "$latest_nightly_date 1 day")"
	local latest_version="$latest_nightly_version-${latest_nightly_date//-/.}-nightly"

	if [[ "${latest_version}" == "${TERMUX_PKG_VERSION}" ]]; then
		echo "INFO: No update needed. Already at version '${TERMUX_PKG_VERSION}'."
		rm -rf ~/.cargo ~/.rustup
		return
	elif [ "$(echo "$latest_version $TERMUX_PKG_VERSION" | tr " " "\n" | sort -V | head -n 1)" == "$latest_version" ]; then
		echo "Error: It seems that rustc-nightly version $latest_version is withdrawed."
		rm -rf ~/.cargo ~/.rustup
		exit 1
	fi

	rm -rf ~/.cargo ~/.rustup
	wget -q "https://static.rust-lang.org/dist/$latest_nightly_date/rustc-nightly-src.tar.xz" -O /tmp/rustc-nightly-src.tar.xz
	local _sha256_checksum="$(sha256sum /tmp/rustc-nightly-src.tar.xz | cut -d' ' -f1)"
	rm -f /tmp/rustc-nightly-src.tar.xz
	echo "Version : $latest_version"
	echo "Checksum: $_sha256_checksum"
	termux_pkg_upgrade_version "$latest_version"
}

termux_step_post_get_source() {
	local _rust_version="$(cat version | cut -d- -f1)"
	if [ "$_rust_version" != "$_RUST_VERSION" ]; then
		termux_error_exit "Version mismatch: Expected $_RUST_VERSION, got $_rust_version."
	fi
}

termux_step_pre_configure() {
	termux_setup_cmake
	termux_setup_rust

	# default rust-nightly-std package to be installed
	TERMUX_PKG_DEPENDS+=", rust-nightly-std-${CARGO_TARGET_NAME/_/-}"

	local p="${TERMUX_PKG_BUILDER_DIR}/0001-set-TERMUX_PKG_API_LEVEL.diff"
	echo "Applying patch: $(basename "${p}")"
	sed "s|@TERMUX_PKG_API_LEVEL@|${TERMUX_PKG_API_LEVEL}|g" "${p}" \
		| patch --silent -p1

	export RUST_LIBDIR=$TERMUX_PKG_BUILDDIR/_lib
	mkdir -p $RUST_LIBDIR

	# we can't use -L$PREFIX/lib since it breaks things but we need to link against libLLVM-9.so
	ln -vfst "${RUST_LIBDIR}" \
		${TERMUX_PREFIX}/lib/libLLVM-${_LLVM_MAJOR_VERSION}.so

	# https://github.com/termux/termux-packages/issues/18379
	# NDK r26 multiple ld.lld: error: undefined symbol: __cxa_*
	ln -vfst "${RUST_LIBDIR}" "${TERMUX_PREFIX}"/lib/libc++_shared.so

	# https://github.com/termux/termux-packages/issues/11640
	# https://github.com/termux/termux-packages/issues/11658
	# The build system somehow tries to link binaries against a wrong libc,
	# leading to build failures for arm and runtime errors for others.
	# The following command is equivalent to
	#	ln -vfst $RUST_LIBDIR \
	#		$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/$TERMUX_PKG_API_LEVEL/lib{c,dl}.so
	# but written in a future-proof manner.
	ln -vfst $RUST_LIBDIR $(echo | $CC -x c - -Wl,-t -shared | grep '\.so$')

	ln -vfst "${RUST_LIBDIR}" "${TERMUX_PREFIX}"/lib/libandroid-execinfo.so
}

termux_step_configure() {
	# Install llvm-19
	local _line="deb [arch=amd64] http://apt.llvm.org/noble/ llvm-toolchain-noble-19 main"
	local _file="/etc/apt/sources.list.d/apt-llvm-org.list"
	__sudo grep -qF -- "$_line" "$_file" || \
		echo "$_line" | __sudo tee -a "$_file"
	__sudo apt update
	__sudo apt install -y llvm-19-dev llvm-19-tools

	# Use nightly toolchain to build nightly toolchain
	if [[ "${TERMUX_ON_DEVICE_BUILD}" == "false" ]]; then
		rustup install nightly
		export PATH="${HOME}/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin:${PATH}"
	fi
	local RUSTC=$(command -v rustc)
	local CARGO=$(command -v cargo)

	if [[ "${TERMUX_ON_DEVICE_BUILD}" == "true" ]]; then
		local dir="${TERMUX_STANDALONE_TOOLCHAIN}/toolchains/llvm/prebuilt/linux-x86_64/bin"
		mkdir -p "${dir}"
		local target clang
		for target in aarch64-linux-android armv7a-linux-androideabi i686-linux-android x86_64-linux-android; do
			for clang in clang clang++; do
				ln -fsv "${TERMUX_PREFIX}/bin/clang" "${dir}/${target}${TERMUX_PKG_API_LEVEL}-${clang}"
			done
		done
	fi

	RUST_NIGHTLY_PREFIX="$TERMUX_PREFIX"/opt/rust-nightly
	mkdir -p "$RUST_NIGHTLY_PREFIX"

	sed \
		-e "s|@RUST_PREFIX@|${RUST_NIGHTLY_PREFIX}|g" \
		-e "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|g" \
		-e "s|@TERMUX_STANDALONE_TOOLCHAIN@|${TERMUX_STANDALONE_TOOLCHAIN}|g" \
		-e "s|@CARGO_TARGET_NAME@|${CARGO_TARGET_NAME}|g" \
		-e "s|@RUSTC@|${RUSTC}|g" \
		-e "s|@CARGO@|${CARGO}|g" \
		"${TERMUX_PKG_BUILDER_DIR}"/config.toml > config.toml

	local env_host=$(printf $CARGO_TARGET_NAME | tr a-z A-Z | sed s/-/_/g)
	export ${env_host}_OPENSSL_DIR=$TERMUX_PREFIX
	export RUST_LIBDIR=$TERMUX_PKG_BUILDDIR/_lib
	export CARGO_TARGET_${env_host}_RUSTFLAGS="-L${RUST_LIBDIR}"

	# x86_64: __lttf2
	case "${TERMUX_ARCH}" in
	x86_64)
		export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=$(${CC} -print-libgcc-file-name)" ;;
	esac

	# NDK r26
	export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=-lc++_shared"

	# rust 1.79.0
	# note: ld.lld: error: undefined reference due to --no-allow-shlib-undefined: syncfs
	"${CC}" ${CPPFLAGS} -c "${TERMUX_PKG_BUILDER_DIR}/syncfs.c"
	"${AR}" rcu "${RUST_LIBDIR}/libsyncfs.a" syncfs.o
	export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=-l:libsyncfs.a"

	# rust 1.87.0
	# note: ld.lld: error: undefined reference due to --no-allow-shlib-undefined: backtrace
	export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=-landroid-execinfo"

	# Add rpath
	export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=-Wl,-rpath=\$ORIGIN/../lib"
	export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=-Wl,-rpath=$RUST_NIGHTLY_PREFIX/lib"
	export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=-Wl,-rpath=${TERMUX_PREFIX}/lib -C link-arg=-Wl,--enable-new-dtags"

	unset CC CFLAGS CFLAGS_${env_host} CPP CPPFLAGS CXX CXXFLAGS LD LDFLAGS PKG_CONFIG RANLIB
}

termux_step_make() {
	:
}

termux_step_make_install() {
	# install causes on device build fail to continue
	# dist uses a lot of spaces on CI
	local job="install"
	[[ "${TERMUX_ON_DEVICE_BUILD}" == "true" ]] && job="dist"

	"${TERMUX_PKG_SRCDIR}/x.py" ${job} -j ${TERMUX_PKG_MAKE_PROCESSES} --stage 1

	# Not putting wasm32-* into config.toml
	# CI and on device (wasm32*):
	# error: could not document `std`
	"${TERMUX_PKG_SRCDIR}/x.py" install -j ${TERMUX_PKG_MAKE_PROCESSES} --target wasm32-unknown-unknown --stage 1 std
	[[ ! -e "${TERMUX_PREFIX}/share/wasi-sysroot" ]] && termux_error_exit "wasi-sysroot not found"
	"${TERMUX_PKG_SRCDIR}/x.py" install -j ${TERMUX_PKG_MAKE_PROCESSES} --target wasm32-wasip1 --stage 1 std
	"${TERMUX_PKG_SRCDIR}/x.py" install -j ${TERMUX_PKG_MAKE_PROCESSES} --target wasm32-wasip2 --stage 1 std

	"${TERMUX_PKG_SRCDIR}/x.py" dist -j ${TERMUX_PKG_MAKE_PROCESSES} rustc-dev

	local VERSION=nightly

	if [[ "${TERMUX_ON_DEVICE_BUILD}" == "true" ]]; then
		echo "WARN: Replacing on device rust! Caveat emptor!"
		rm -fr ${RUST_NIGHTLY_PREFIX}/lib/rustlib/${CARGO_TARGET_NAME}
		rm -fv $(find ${RUST_NIGHTLY_PREFIX}/lib -maxdepth 1 -type l -exec ls -l "{}" \; | grep rustlib | sed -e "s|.* ${RUST_NIGHTLY_PREFIX}/lib|${RUST_NIGHTLY_PREFIX}/lib|" -e "s| -> .*||")
	fi
	ls build/dist/*-${VERSION}*.tar.gz | xargs -P${TERMUX_PKG_MAKE_PROCESSES} -n1 -t -r tar -xf
	local tgz
	for tgz in $(ls build/dist/*-${VERSION}*.tar.gz); do
		echo "INFO: ${tgz}"
		./$(basename "${tgz}" | sed -e "s|.tar.gz$||")/install.sh --prefix=${RUST_NIGHTLY_PREFIX}
	done

	cd "$TERMUX_PREFIX/lib"
	rm -fv libc.so libdl.so

	cd "$RUST_NIGHTLY_PREFIX/lib"
	ln -vfs rustlib/${CARGO_TARGET_NAME}/lib/*.so .
	ln -vfs "$TERMUX_PREFIX"/bin/lld ${RUST_NIGHTLY_PREFIX}/bin/rust-lld

	cd "$RUST_NIGHTLY_PREFIX/lib/rustlib"
	rm -fr \
		components \
		install.log \
		uninstall.sh \
		rust-installer-version \
		manifest-* \
		x86_64-unknown-linux-gnu

	cd "${RUST_NIGHTLY_PREFIX}/lib/rustlib/${CARGO_TARGET_NAME}/lib"
	echo "INFO: ${TERMUX_PKG_BUILDDIR}/rustlib-rlib.txt"
	ls *.rlib | tee "${TERMUX_PKG_BUILDDIR}/rustlib-rlib.txt"

	echo "INFO: ${TERMUX_PKG_BUILDDIR}/rustlib-so.txt"
	ls *.so | tee "${TERMUX_PKG_BUILDDIR}/rustlib-so.txt"

	echo "INFO: ${TERMUX_PKG_BUILDDIR}/rustc-dev-${VERSION}-${CARGO_TARGET_NAME}/rustc-dev/manifest.in"
	cat "${TERMUX_PKG_BUILDDIR}/rustc-dev-${VERSION}-${CARGO_TARGET_NAME}/rustc-dev/manifest.in" | tee "${TERMUX_PKG_BUILDDIR}/manifest.in"

	sed -e 's/^.....//' -i "${TERMUX_PKG_BUILDDIR}/manifest.in"
	local _included=$(cat "${TERMUX_PKG_BUILDDIR}/manifest.in")
	local _included_rlib=$(echo "${_included}" | grep '\.rlib$')
	local _included_so=$(echo "${_included}" | grep '\.so$')
	local _included=$(echo "${_included}" | grep -v "/rustc-src/")
	local _included=$(echo "${_included}" | grep -v '\.rlib$')
	local _included=$(echo "${_included}" | grep -v '\.so$')

	echo "INFO: _rlib"
	while IFS= read -r _rlib; do
		echo "${_rlib}"
		local _included_rlib=$(echo "${_included_rlib}" | grep -v "${_rlib}")
	done < "${TERMUX_PKG_BUILDDIR}/rustlib-rlib.txt"
	echo "INFO: _so"
	while IFS= read -r _so; do
		echo "${_so}"
		local _included_so=$(echo "${_included_so}" | grep -v "${_so}")
	done < "${TERMUX_PKG_BUILDDIR}/rustlib-so.txt"

	export _INCLUDED="$(echo -e "${_included}\n${_included_rlib}\n${_included_so}" | xargs -I {} echo "opt/rust-nightly/{}")"
	echo -e "INFO: _INCLUDED:\n${_INCLUDED}"
}

termux_step_post_make_install() {
	if [ "$TERMUX_ARCH_BITS" = "64" ]; then
		mkdir -p $TERMUX_PREFIX/opt/rust-nightly/lib/rustlib/$CARGO_TARGET_NAME/codegen-backends/
		cp build/$CARGO_TARGET_NAME/stage1/lib/rustlib/$CARGO_TARGET_NAME/codegen-backends/librustc_codegen_cranelift-$_RUST_VERSION-nightly.so \
			$TERMUX_PREFIX/opt/rust-nightly/lib/rustlib/$CARGO_TARGET_NAME/codegen-backends/librustc_codegen_cranelift-$_RUST_VERSION-nightly.so
	fi

	mkdir -p $TERMUX_PREFIX/etc/profile.d
	echo "#!$TERMUX_PREFIX/bin/sh" > $TERMUX_PREFIX/etc/profile.d/rust-nightly.sh
	echo "export PATH=$RUST_NIGHTLY_PREFIX/bin:\$PATH" >> $TERMUX_PREFIX/etc/profile.d/rust-nightly.sh
}

termux_step_create_debscripts() {
	echo "#!$TERMUX_PREFIX/bin/sh" > postinst
	echo "echo 'source \$PREFIX/etc/profile.d/rust-nightly.sh to use nightly'" >> postinst
	echo "echo 'or export RUSTC=\$PREFIX/opt/rust-nightly/bin/rustc'" >> postinst
}
