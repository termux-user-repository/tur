TERMUX_PKG_HOMEPAGE="https://github.com/shader-slang/slang"
TERMUX_PKG_DESCRIPTION="Shading language that makes it easier to build and maintain large shader codebases in a modular and extensible fashion"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@otreblan"
TERMUX_PKG_VERSION="2026.10"
TERMUX_PKG_REVISION=1
_SLANG_LUA_VERSION="5.5.0"
_SLANG_CMARK_VERSION="0.8.0"
_SLANG_MINIZ_VERSION="3.1.1"
_SLANG_UNORDERED_DENSE_VERSION="4.8.1"
TERMUX_PKG_SRCURL=(
	"$TERMUX_PKG_HOMEPAGE/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
	"https://github.com/lua/lua/archive/refs/tags/v$_SLANG_LUA_VERSION.tar.gz"
	"https://github.com/swiftlang/swift-cmark/archive/refs/tags/$_SLANG_CMARK_VERSION.tar.gz"
	"https://github.com/richgel999/miniz/archive/refs/tags/$_SLANG_MINIZ_VERSION.tar.gz"
	"https://github.com/martinus/unordered_dense/archive/refs/tags/v$_SLANG_UNORDERED_DENSE_VERSION.tar.gz"
)
TERMUX_PKG_SHA256=(
	"ccf89641ac8b30f1c90bad33dff04ae7ee4152d4553a1d416bcaad3a1a0efda3"
	"a33484f7ce4c14e12ea4d51cc5a7353bff2796a8074004b96ae2dc246f33f16e"
	"bb755e2a28fac2eb6b02981fbc72cc11e225a726d71ddffd0091055984261a16"
	"8bb29c7bd6f22356e5583e794bed4a0b3e6dfcbcadb49974fc9270ccca1e5557"
	"9f7202ec6d8353932ef865d33f5872e4b7a1356e9032da7cd09c3a0c5bb2b7de"
)
TERMUX_PKG_DEPENDS="glslang, libandroid-spawn, libc++, lz4, spirv-tools"
TERMUX_PKG_BUILD_DEPENDS="clang, cmake, git, glm, python, spirv-headers, stb, vulkan-headers, vulkan-loader"
TERMUX_PKG_CMAKE_BUILD="Unix Makefiles"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DCMAKE_BUILD_TYPE=None
-DSLANG_VERSION_NUMERIC=$TERMUX_PKG_VERSION
-DSLANG_VERSION_FULL=v$TERMUX_PKG_VERSION
-DSLANG_ENABLE_RELEASE_DEBUG_INFO=FALSE
-DSLANG_ENABLE_SPLIT_DEBUG_INFO=FALSE
-DSLANG_ENABLE_TESTS=FALSE
-DSLANG_ENABLE_SLANG_RHI=FALSE
-DSLANG_USE_SYSTEM_LZ4=TRUE
-DSLANG_USE_SYSTEM_VULKAN_HEADERS=TRUE
-DSLANG_USE_SYSTEM_SPIRV_HEADERS=TRUE
-DSLANG_USE_SYSTEM_SPIRV_TOOLS=TRUE
-DSLANG_USE_SYSTEM_GLSLANG=TRUE
-DSLANG_SLANG_LLVM_FLAVOR=DISABLE
-DSLANG_ENABLE_GFX=FALSE
-DSLANG_OVERRIDE_LUA_PATH=$TERMUX_PKG_BUILDDIR
-DSLANG_OVERRIDE_CMARK_PATH=$TERMUX_PKG_BUILDDIR
-DSLANG_OVERRIDE_MINIZ_PATH=$TERMUX_PKG_BUILDDIR
-DSLANG_OVERRIDE_UNORDERED_DENSE_PATH=$TERMUX_PKG_BUILDDIR
"
# Delete Unix backward compatibility symlink (libslang -> libslang-compiler)
TERMUX_PKG_RM_AFTER_INSTALL="
lib/libslang.so
"

termux_step_post_get_source() {
	ln -s "$TERMUX_PKG_SRCDIR/lua-$_SLANG_LUA_VERSION"                         "$TERMUX_PKG_BUILDDIR/lua"
	ln -s "$TERMUX_PKG_SRCDIR/swift-cmark-$_SLANG_CMARK_VERSION"               "$TERMUX_PKG_BUILDDIR/cmark"
	ln -s "$TERMUX_PKG_SRCDIR/miniz-$_SLANG_MINIZ_VERSION"                     "$TERMUX_PKG_BUILDDIR/miniz"
	ln -s "$TERMUX_PKG_SRCDIR/unordered_dense-$_SLANG_UNORDERED_DENSE_VERSION" "$TERMUX_PKG_BUILDDIR/unordered_dense"

	cd "$TERMUX_PKG_SRCDIR"

	sed -e "s/\(find_package(LLVM \)\([^ ]\+\) /\1/" \
		-i cmake/LLVM.cmake

	find tools/gfx/vulkan/ \
		\( -name "*.cpp" -or -name "*.h" \) \
		-exec \
			sed -e 's/"spirv-tools\/include\/\(.*\)"/<\1>/g' \
			-i {} \+

	# Add include prefix
	sed -e 's/${CMAKE_INSTALL_INCLUDEDIR}/&\/'"$TERMUX_PKG_NAME"'/g' \
		-i cmake/SlangTarget.cmake

	# Disable double header install
	perl -0777 -pi -e 's/install\s*\(\s*DIRECTORY\s*"\$\{slang_SOURCE_DIR\}\/include\".*?\)\s*//s' \
		CMakeLists.txt

	# https://github.com/shader-slang/slang/pull/8369#issuecomment-3255737218
	sed -e 's/#include "\(SPIRV\/.*\)"/#include <glslang\/\1>/g' \
		-i source/slang-glslang/slang-glslang.cpp

	# Use system stb
	sed -e 's#${CMAKE_CURRENT_LIST_DIR}/stb#/usr/include/stb#' \
		-i external/CMakeLists.txt

	# Link with libandroid-spawn
	sed -e 's/LINK_WITH_PRIVATE/& android-spawn/' -i source/{core,slang-rt}/CMakeLists.txt

	# TODO cross-compilation: https://github.com/shader-slang/slang/blob/master/docs/building.md
}
