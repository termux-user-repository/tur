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

	# --- ESCUDOS DE CROSS-COMPILING (INYECCIÓN DIRECTA EN CMAKE) ---
	# 1. Evita que CMake intente ejecutar binarios de test en el servidor
	sed -i "1i set(DUCKDB_PLATFORM \"android_${TERMUX_ARCH}\")" CMakeLists.txt

	# 2. Falsifica las firmas de Git para evitar que asigne la versión v0.0.1
	sed -i "1i set(OVERRIDE_GIT_DESCRIBE \"v${TERMUX_PKG_VERSION}-0-g0000000\")" CMakeLists.txt
	sed -i "1i set(GIT_COMMIT_HASH \"0000000\")" CMakeLists.txt
}

termux_step_make_install() {
	# Limitamos a 2 hilos para evitar que GitHub Actions muera por falta de RAM (OOM)
	export CMAKE_BUILD_PARALLEL_LEVEL=2
	export MAX_JOBS=2

	export CMAKE_GENERATOR="Ninja"
	export SKBUILD_CMAKE_GENERATOR="Ninja"

	export CFLAGS+=" -O3 -fPIC -pipe"
	export CXXFLAGS+=" -O3 -fPIC -pipe"

	echo "[*] Fundiendo DuckDB (v${TERMUX_PKG_VERSION}) en modo cruzado seguro..."

	export PYTHONPATH=$(pwd):$PYTHONPATH

	pip3 install . \
		--prefix="${TERMUX_PREFIX}" \
		--no-build-isolation \
		--no-deps \
		--break-system-packages \
		-v
}
