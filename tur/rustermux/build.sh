TERMUX_PKG_HOMEPAGE="https://github.com/SSL-ACTX/rustermux"
TERMUX_PKG_DESCRIPTION="Official GNU Rustup toolchain on Android Termux via Glibc"
TERMUX_PKG_LICENSE="MIT, Apache-2.0"
TERMUX_PKG_MAINTAINER="Seuriin <seuriin@gmail.com>"
TERMUX_PKG_VERSION="1.1.0"
TERMUX_PKG_SRCURL="https://github.com/SSL-ACTX/rustermux/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="a1c9dc4d796a0c994a481c9bf22ee5318ceb36de4121e503c8888b1b138a5aaa"
TERMUX_PKG_DEPENDS="binutils-glibc, ca-certificates-glibc, curl, file, gcc-glibc, glibc, glibc-runner, patchelf-glibc"
TERMUX_PKG_RECOMMENDS="mold, sccache"
TERMUX_PKG_PROVIDES="rust, cargo"
TERMUX_PKG_CONFLICTS="rust, rust-nightly"

termux_step_make_install() {
	mkdir -p "$TERMUX_PREFIX/share/rustermux"
	cp -r "$TERMUX_PKG_SRCDIR/wrappers" "$TERMUX_PREFIX/share/rustermux/"
	cp "$TERMUX_PKG_SRCDIR/patch.sh" "$TERMUX_PREFIX/share/rustermux/"
	cp "$TERMUX_PKG_SRCDIR/install.sh" "$TERMUX_PREFIX/share/rustermux/"
	chmod +x "$TERMUX_PREFIX/share/rustermux/install.sh"
	chmod +x "$TERMUX_PREFIX/share/rustermux/patch.sh"
	chmod +x "$TERMUX_PREFIX/share/rustermux/wrappers"/*

	mkdir -p "$TERMUX_PREFIX/bin"
	install -m 755 "$TERMUX_PKG_SRCDIR/wrappers/maturin" "$TERMUX_PREFIX/bin/maturin-wrapper"

	cat <<- 'EOF' > "$TERMUX_PREFIX/bin/rustermux"
		#!/data/data/com.termux/files/usr/bin/bash
		exec /data/data/com.termux/files/usr/share/rustermux/install.sh "$@"
	EOF
	chmod 755 "$TERMUX_PREFIX/bin/rustermux"
}
