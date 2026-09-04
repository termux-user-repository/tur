TERMUX_PKG_HOMEPAGE="https://duckdb.org/"
TERMUX_PKG_DESCRIPTION="DuckDB is an in-process SQL OLAP database management system"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@pablobp10"

TERMUX_PKG_VERSION="1.5.5"
TERMUX_PKG_SRCURL="https://files.pythonhosted.org/packages/source/d/duckdb/duckdb-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="72f33ee57ca7595b23957671a2cc7f7fe2be0ecc2d68f63abedcfcaa3a5c1238"

TERMUX_PKG_DEPENDS="python, libc++"
TERMUX_PKG_BUILD_DEPENDS="cmake, ninja"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
# ¡LA PIEZA QUE FALTABA! Descarga CMake 4.4.3 y Ninja para el Host
# y genera el TERMUX_CMAKE_CROSSCOMPILING_TOOLCHAIN
termux_setup_cmake
termux_setup_ninja

pip3 install setuptools_scm scikit-build-core nanobind --break-system-packages
}

termux_step_configure() {
return 0
}

termux_step_make() {
return 0
}

termux_step_make_install() {
export DUCKDB_PLATFORM="android-${TERMUX_ARCH}"

# Alimentamos a scikit-build-core con el toolchain de Termux
export SKBUILD_CMAKE_ARGS="-DCMAKE_TOOLCHAIN_FILE=${TERMUX_CMAKE_CROSSCOMPILING_TOOLCHAIN} -DDUCKDB_PLATFORM=${DUCKDB_PLATFORM}"
export CMAKE_ARGS="-DCMAKE_TOOLCHAIN_FILE=${TERMUX_CMAKE_CROSSCOMPILING_TOOLCHAIN} -DDUCKDB_PLATFORM=${DUCKDB_PLATFORM}"

export MAX_JOBS=2
export CMAKE_BUILD_PARALLEL_LEVEL=2

export CFLAGS+=" -O3 -fPIC -pipe"
export CXXFLAGS+=" -O3 -fPIC -pipe"

export PYTHONPATH="$(pwd):${PYTHONPATH:-}"

echo "[*] Fundiendo DuckDB (v${TERMUX_PKG_VERSION}) nativo desde PyPI con scikit-build-core..."

pip3 install . \
--prefix="${TERMUX_PREFIX}" \
--no-build-isolation \
--no-deps \
--break-system-packages \
-v
}
