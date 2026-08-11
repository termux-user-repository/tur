TERMUX_PKG_HOMEPAGE="https://github.com/Natarizki/bada-lang"
TERMUX_PKG_DESCRIPTION="Bada programming language compiler - hybrid C/Rust-style language with LLVM backend"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@Natarizki"
TERMUX_PKG_VERSION="1.2.0"
TERMUX_PKG_SRCURL="https://github.com/Natarizki/bada-lang/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="4974361fae81873bd592f1c2c4b84882249187684d4c0b4fbe982c354c71da20"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="llvm"
TERMUX_PKG_BUILD_DEPENDS="llvm, clang, cmake, ninja"

termux_step_make() {
	cmake \
		-G Ninja \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX="${TERMUX_PREFIX}" \
		-DCMAKE_CXX_COMPILER="${CXX}" \
		-DLLVM_DIR="$(${TERMUX_PREFIX}/bin/llvm-config --cmakedir 2>/dev/null || echo '')" \
		-B "${TERMUX_PKG_BUILDER_DIR}/build" \
		"${TERMUX_PKG_SRCDIR}"
	ninja -C "${TERMUX_PKG_BUILDER_DIR}/build"
}

termux_step_make_install() {
	install -Dm755 \
		"${TERMUX_PKG_BUILDER_DIR}/build/bada" \
		"${TERMUX_PREFIX}/bin/bada"

	install -d "${TERMUX_PREFIX}/share/doc/bada"
	install -Dm644 \
		"${TERMUX_PKG_SRCDIR}/README.md" \
		"${TERMUX_PREFIX}/share/doc/bada/README.md"
}
