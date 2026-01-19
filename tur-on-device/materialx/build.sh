TERMUX_PKG_HOMEPAGE=https://materialx.org/
TERMUX_PKG_DESCRIPTION="Open standard for the exchange of rich material and look-development content in computer graphics"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.39.4"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL="https://github.com/AcademySoftwareFoundation/MaterialX/releases/download/v$TERMUX_PKG_VERSION/MaterialX-$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=5335565de46195031763951d7bec29a3a2fa96656d9cf3972e1408b2578f7ebe
TERMUX_PKG_DEPENDS="libc++, opencolorio, opengl, openimageio, python, zenity"
TERMUX_PKG_MAKE_DEPENDS="dos2unix, pybind11"
# viewer and graph editor GUIs depend on git submodules and an
# old version of GLFW that is tedious to patch.
# Enable if strongly desired.
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DMATERIALX_BUILD_SHARED_LIBS=ON
-DMATERIALX_BUILD_PYTHON=ON
-DMATERIALX_BUILD_VIEWER=OFF
-DMATERIALX_BUILD_GRAPH_EDITOR=OFF
-DMATERIALX_BUILD_OIIO=ON
-DMATERIALX_BUILD_OCIO=ON
"

# The default installation paths of this software are very messy if not manually corrected.
# Using packaging file structure fixes based on Arch Linux:
# https://gitlab.archlinux.org/archlinux/packaging/packages/materialx/-/blob/bbc9215b7c941ff45cee19b2386ca7ce5e65dd96/PKGBUILD
termux_step_pre_configure() {
	if [[ "$TERMUX_ON_DEVICE_BUILD" == "false" ]]; then
		termux_error_exit "This package is extremely hard to cross-compile. If you know how, please help!"
	fi

	sed -i "s|CMAKE_INSTALL_PREFIX|CMAKE_BINARY_DIR|g" python/CMakeLists.txt

	sed -i "s|resources|$TERMUX_PREFIX/share/materialx/resources|g" source/MaterialXView/{Main.cpp,Viewer.cpp}
	sed -i "s|\"libraries\"|\"$TERMUX_PREFIX/share/materialx/libraries\"|g" source/MaterialXView/Main.cpp
	sed -i "s|resources|$TERMUX_PREFIX/share/materialx/resources|g" source/MaterialXGraphEditor/{Main.cpp,Graph.cpp}
	sed -i "s|\"libraries\"|\"$TERMUX_PREFIX/share/materialx/libraries\"|g" source/MaterialXGraphEditor/{Main.cpp,Graph.cpp}
	sed -i "s|\"libraries\"|\"$TERMUX_PREFIX/share/materialx/libraries\"|g" source/MaterialXGenShader/GenOptions.h

	dos2unix python/Scripts/*

	export LDFLAGS+=" -lpython$TERMUX_PYTHON_VERSION"
}

termux_step_post_make_install() {
	rm "$TERMUX_PREFIX"/{LICENSE,CHANGELOG.md,README.md,THIRD-PARTY.md}
	rm "$TERMUX_PREFIX/python/Scripts/README.md"
	local file name
	for file in "$TERMUX_PREFIX"/python/Scripts/*; do
		name="${file%.py}"
		chmod +x "$file"
		mv "$file" "$name"
	done

	rm -rf "$TERMUX_PREFIX/share/$TERMUX_PKG_NAME"
	mkdir -p "$TERMUX_PREFIX/share/$TERMUX_PKG_NAME"
	mv -f "$TERMUX_PREFIX"/{resources,libraries} "$TERMUX_PREFIX/share/$TERMUX_PKG_NAME/"
	cp "$TERMUX_PREFIX"/python/Scripts/* "$TERMUX_PREFIX/bin/"
	rm -r "$TERMUX_PREFIX/python/Scripts/"
	mkdir -p "$TERMUX_PREFIX/lib/python$TERMUX_PYTHON_VERSION/site-packages"
	rm -rf "$TERMUX_PREFIX/lib/python$TERMUX_PYTHON_VERSION/site-packages"/MaterialX*
	mv "$TERMUX_PREFIX"/python/* "$TERMUX_PREFIX/lib/python$TERMUX_PYTHON_VERSION/site-packages/"

	sed -i 's|libraries|share/materialx/libraries|g' "$TERMUX_PREFIX/lib/cmake/MaterialX/MaterialXConfig.cmake"
	sed -i 's|python|lib/python'$TERMUX_PYTHON_VERSION'/site-packages/MaterialX|g' "$TERMUX_PREFIX/lib/cmake/MaterialX/MaterialXConfig.cmake"
	sed -i 's|resources|share/materialx/resources|g' "$TERMUX_PREFIX/lib/cmake/MaterialX/MaterialXConfig.cmake"
}
