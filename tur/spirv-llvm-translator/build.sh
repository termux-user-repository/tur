TERMUX_PKG_HOMEPAGE=https://github.com/KhronosGroup/SPIRV-LLVM-Translator
TERMUX_PKG_DESCRIPTION="Tool and a library for bi-directional translation between SPIR-V and LLVM IR"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE.TXT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=20.1.1
TERMUX_PKG_SRCURL=https://github.com/KhronosGroup/SPIRV-LLVM-Translator/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=3b2a750bbaea4a084e90fd88de317f9a03879056e3bd429bb56c588f4c77ca16
TERMUX_PKG_DEPENDS="libllvm, spirv-tools"
TERMUX_PKG_BUILD_DEPENDS="libllvm, libllvm-static, llvmgold, mlir, libpolly"
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DLLVM_INCLUDE_TESTS=ON
-DLLVM_EXTERNAL_LIT=$TERMUX_PREFIX/bin/lit
-DLLVM_CONFIG_PATH=$TERMUX_PKG_HOSTBUILD_DIR/bin/llvm-config
"