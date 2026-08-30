TERMUX_PKG_HOMEPAGE="https://duckdb.org/"
TERMUX_PKG_DESCRIPTION="DuckDB is an in-process SQL OLAP database management system"
TERMUX_PKG_LICENSE="MIT"

TERMUX_PKG_VERSION="1.5.5"
TERMUX_PKG_SHA256="72f33ee57ca7595b23957671a2cc7f7fe2be0ecc2d68f63abedcfcaa3a5c1238"

TERMUX_PKG_DEPENDS="python, libc++, libexecinfo"
TERMUX_PKG_BUILD_DEPENDS="cmake, ninja, python-pip, python-setuptools-scm, pybind11"

TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_ninja
	termux_setup_cmake
	termux_setup_python_crossenv
}

termux_step_make_install() {
	export CMAKE_BUILD_PARALLEL_LEVEL=$TERMUX_MAKE_PROCESSES
	export MAX_JOBS=$TERMUX_MAKE_PROCESSES

	export CMAKE_GENERATOR="Ninja"
	export SKBUILD_CMAKE_GENERATOR="Ninja"

	export CMAKE_ARGS="-DCMAKE_TOOLCHAIN_FILE=${TERMUX_CMAKE_CROSSCOMPILING_TOOLCHAIN}"
	export SKBUILD_CMAKE_ARGS="-DCMAKE_TOOLCHAIN_FILE=${TERMUX_CMAKE_CROSSCOMPILING_TOOLCHAIN}"

	export LDFLAGS+=" -lexecinfo"
	export CFLAGS+=" -O3 -fPIC -pipe"
	export CXXFLAGS+=" -O3 -fPIC -pipe"

	echo "[*] Fundiendo DuckDB (v${TERMUX_PKG_VERSION}) con $MAX_JOBS hilos y Ninja en modo Cruzado..."

	export PYTHONPATH=$(pwd):$PYTHONPATH

	pip3 install . \
		--prefix="${TERMUX_PREFIX}" \
		--no-build-isolation \
		--no-deps \
		-v
}
