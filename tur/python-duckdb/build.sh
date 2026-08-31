TERMUX_PKG_HOMEPAGE="https://duckdb.org/"
TERMUX_PKG_DESCRIPTION="DuckDB is an in-process SQL OLAP database management system"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@pablobp10"

TERMUX_PKG_VERSION="1.5.5"
TERMUX_PKG_SRCURL="https://github.com/duckdb/duckdb/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="f33155ff962e6e1e08fd1e9caffa487d4325aa60999e2eabc76feff534d6558b"

TERMUX_PKG_DEPENDS="python, libc++"
TERMUX_PKG_BUILD_DEPENDS="cmake, ninja, pybind11"

TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_ninja
	termux_setup_cmake
	pip3 install setuptools_scm --break-system-packages
}

termux_step_make_install() {
	# ---------------------------------------------------------
	# ESCUDOS DE COMPILACIÓN CRUZADA (CROSS-COMPILING SHIELDS)
	# ---------------------------------------------------------
	# 1. Forzar la plataforma para evitar el "Exec format error"
	export DUCKDB_PLATFORM="android-${TERMUX_ARCH}"
	
	# 2. Engañar a Git para evitar el paquete corrupto "v0.0.1"
	export OVERRIDE_GIT_DESCRIBE="v${TERMUX_PKG_VERSION}"
	export SETUPTOOLS_SCM_PRETEND_VERSION="${TERMUX_PKG_VERSION}"
	
	# 3. Limitar los hilos para que GitHub Actions no se quede sin memoria (OOM Kill)
	export CMAKE_BUILD_PARALLEL_LEVEL=2
	export MAX_JOBS=2
	# ---------------------------------------------------------

	export CMAKE_GENERATOR="Ninja"
	export SKBUILD_CMAKE_GENERATOR="Ninja"

	export CMAKE_ARGS="-DCMAKE_TOOLCHAIN_FILE=${TERMUX_CMAKE_CROSSCOMPILING_TOOLCHAIN} -DDUCKDB_PLATFORM=${DUCKDB_PLATFORM}"
	export SKBUILD_CMAKE_ARGS="-DCMAKE_TOOLCHAIN_FILE=${TERMUX_CMAKE_CROSSCOMPILING_TOOLCHAIN} -DDUCKDB_PLATFORM=${DUCKDB_PLATFORM}"

	export CFLAGS+=" -O3 -fPIC -pipe"
	export CXXFLAGS+=" -O3 -fPIC -pipe"

	echo "[*] Fundiendo DuckDB (v${TERMUX_PKG_VERSION}) para ${DUCKDB_PLATFORM}..."

	export PYTHONPATH=$(pwd):$PYTHONPATH

	pip3 install . \
		--prefix="${TERMUX_PREFIX}" \
		--no-build-isolation \
		--no-deps \
		--break-system-packages \
		-v
}
