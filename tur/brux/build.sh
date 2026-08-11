TERMUX_PKG_HOMEPAGE=https://github.com/KelvinShadewing/brux-gdk
TERMUX_PKG_DESCRIPTION="Free runtime and development kit using SDL and Squirrel"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=2026.01.07
TERMUX_PKG_SRCURL=git+https://github.com/KelvinShadewing/brux-gdk.git
TERMUX_PKG_GIT_BRANCH=main
TERMUX_PKG_DEPENDS="sdl2, sdl2-image, sdl2-net, sdl2-mixer, libcurl, libphysfs, sdl2-gfx, libgit2, libc++, squirrel3, simplesquirrel"
#TERMUX_PKG_BUILD_DEPENDS="cmake, make"
TERMUX_PKG_FORCE_CMAKE=true

termux_step_post_get_source() {
	git submodule update --init --recursive
}

termux_step_pre_configure() {
	termux_setup_cmake
	termux_setup_ninja
	export TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -DCMAKE_ANDROID_STANDALONE_TOOLCHAIN=$TERMUX_STANDALONE_TOOLCHAIN"
	termux_setup_meson
	# Force using system dependencies instead of problematic CMake subprojects
	python3 -c "
import sys
content = open('rte/meson.build').read()

# Replace physfs block
# Note: cat -A showed tabs in the original file
physfs_old = '''if (not physfs.found())
		physfs_proj = cmake.subproject('physfs')

		physfs_lib = physfs_proj.get_variable('physfs')
		physfs = declare_dependency(link_with: physfs_lib, include_directories: physfs_proj.include_directories('physfs'))
endif'''
content = content.replace(\"physfs = dependency('physfs', required: false)\", \"physfs = dependency('physfs', required: true)\")
content = content.replace(physfs_old, '')
content = content.replace(physfs_old.replace('        ', '\t'), '')

# Replace simplesquirrel block
ssq_old = '''if (not simplesquirrel.found())
		opts = cmake.subproject_options()

		opts.add_cmake_defines({'CMAKE_POLICY_VERSION_MINIMUM': '3.5', 'SSQ_USE_SQ_SUBMODULE': true})

		simplesquirrel_proj = cmake.subproject('simplesquirrel', options: opts)

		simplesquirrel_lib = simplesquirrel_proj.get_variable('simplesquirrel_static')
		squirrel_lib = simplesquirrel_proj.get_variable('squirrel_static')
		sqstdlib = simplesquirrel_proj.get_variable('sqstdlib_static')

		simplesquirrel = declare_dependency(link_with: [simplesquirrel_lib, squirrel_lib, sqstdlib], include_directories: simplesquirrel_proj.include_directories('simplesquirrel_static'))
endif'''
ssq_new = '''cpp = meson.get_compiler('cpp')
simplesquirrel_lib = cpp.find_library('simplesquirrel', required: true)
squirrel_lib = cpp.find_library('squirrel', required: true)
sqstdlib_lib = cpp.find_library('sqstdlib', required: true)
simplesquirrel = declare_dependency(dependencies: [simplesquirrel_lib, squirrel_lib, sqstdlib_lib])'''

content = content.replace(\"simplesquirrel = dependency('simplesquirrel', required: false)\", \"simplesquirrel = dependency('simplesquirrel', required: false)\")
content = content.replace(ssq_old, ssq_new)
content = content.replace(ssq_old.replace('        ', '\t'), ssq_new)

open('rte/meson.build', 'w').write(content)
"
}

termux_step_configure() {
	$TERMUX_MESON setup $TERMUX_PKG_BUILDDIR $TERMUX_PKG_SRCDIR/rte \
		--cross-file $TERMUX_MESON_CROSSFILE \
		--prefix $TERMUX_PREFIX \
		--libdir lib \
		--bindir bin \
		--buildtype release
}

termux_step_make() {
	ninja -C $TERMUX_PKG_BUILDDIR
}

termux_step_make_install() {
	$TERMUX_MESON install -C $TERMUX_PKG_BUILDDIR
}
