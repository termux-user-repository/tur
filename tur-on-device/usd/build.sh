TERMUX_PKG_HOMEPAGE=https://openusd.org/
TERMUX_PKG_DESCRIPTION="High-performance extensible software platform for collaboratively constructing animated 3D scenes"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="25.11"
TERMUX_PKG_REVISION=3
TERMUX_PKG_SRCURL="https://github.com/PixarAnimationStudios/OpenUSD/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=c37c633b5037a4552f61574670ecca8836229b78326bd62622f3422671188667
TERMUX_PKG_DEPENDS="alembic, draco, embree, fmt, glew, imath, libc++, libx11, libxt, materialx, libandroid-glob, libtbb, opencolorio, openexr, openimageio, openshadinglanguage, opensubdiv, openvdb, ptex, pyside6, python-opengl"
# a configuration error happens if shared and static opensubdiv are not both installed
TERMUX_PKG_BUILD_DEPENDS="boost-headers, opensubdiv-static"
# Depends on embree, which does not support 32-bit Linux
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DPXR_ENABLE_PYTHON_SUPPORT=ON
-DPYSIDE_AVAILABLE=ON
-DPYSIDEUICBINARY=$TERMUX_PREFIX/lib/qt6/uic
-DPXR_INSTALL_LOCATION=$TERMUX_PREFIX/lib/usd/plugin
-DPXR_BUILD_DOCUMENTATION=OFF
-DPXR_BUILD_EXAMPLES=OFF
-DPXR_BUILD_IMAGING=ON
-DPXR_BUILD_MONOLITHIC=ON
-DPXR_BUILD_TESTS=OFF
-DPXR_BUILD_TUTORIALS=OFF
-DPXR_BUILD_USD_IMAGING=ON
-DPXR_BUILD_USD_TOOLS=ON
-DPXR_BUILD_USDVIEW=ON
-DPXR_VALIDATE_GENERATED_CODE=OFF
-DPXR_BUILD_ALEMBIC_PLUGIN=ON
-DPXR_BUILD_DRACO_PLUGIN=ON
-DPXR_BUILD_EMBREE_PLUGIN=ON
-DPXR_BUILD_OPENCOLORIO_PLUGIN=ON
-DPXR_BUILD_OPENIMAGEIO_PLUGIN=ON
-DPXR_BUILD_PRMAN_PLUGIN=OFF
-DPXR_ENABLE_MATERIALX_SUPPORT=ON
-DPXR_ENABLE_OPENVDB_SUPPORT=ON
-DPXR_ENABLE_HDF5_SUPPORT=ON
-DPXR_ENABLE_PTEX_SUPPORT=ON
-DPXR_ENABLE_OSL_SUPPORT=ON
"

# The default installation paths of this software are very messy if not manually corrected.
# Using packaging file structure fixes based on Arch Linux:
# https://gitlab.archlinux.org/archlinux/packaging/packages/usd/-/blob/b28f3b39accdbedac59eac587551853d9a53928d/PKGBUILD
termux_step_pre_configure() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		termux_error_exit "This package is extremely hard to cross-compile. If you know how, please help!"
	fi

	sed -i 's|plugin/usd|lib/usd/plugin|g' \
		cmake/macros/{Private,Public}.cmake
	sed -i 's|/python|/python'$TERMUX_PYTHON_VERSION'/site-packages|g' \
		cmake/macros/Private.cmake
	sed -i 's|lib/python/pxr|'$TERMUX_PREFIX'/lib/python'$TERMUX_PYTHON_VERSION'/site-packages/pxr|' \
		cmake/macros/{Private,Public}.cmake pxr/usdImaging/usdviewq/CMakeLists.txt

	sed -i \
		-e 's|/pxrConfig.cmake|/lib/cmake/pxr/pxrConfig.cmake|g' \
		-e 's|${CMAKE_INSTALL_PREFIX}|${CMAKE_INSTALL_PREFIX}/lib/cmake/pxr|g' \
		-e 's|"cmake"|"lib/cmake/pxr"|g' \
		pxr/CMakeLists.txt
	sed -i \
		-e 's|${PXR_CMAKE_DIR}/cmake|${PXR_CMAKE_DIR}|g' \
		-e "s|\${PXR_CMAKE_DIR}/include|$TERMUX_PREFIX/include|g" \
		-e 's|EXACT COMPONENTS|COMPONENTS|g' \
		pxr/pxrConfig.cmake.in

	sed -r -i '1{/^#!/d}' \
		pxr/usd/sdr/shaderParserTestUtils.py \
		pxr/usd/usdUtils/updateSchemaWithSdrNode.py \
		pxr/usdImaging/usdviewq/usdviewApi.py


	export LDFLAGS+=" -landroid-glob"
}

termux_step_post_make_install() {
	sed -i 's|${PXR_CMAKE_DIR}/cmake|${PXR_CMAKE_DIR}|g' \
		"$TERMUX_PREFIX/lib/cmake/pxr/pxrConfig.cmake"
	sed -i "s|_IMPORT_PREFIX \"\"|_IMPORT_PREFIX \"$TERMUX_PREFIX\"|" \
		"$TERMUX_PREFIX/lib/cmake/pxr/pxrTargets.cmake"
}
