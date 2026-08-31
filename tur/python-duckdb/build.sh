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
# 1. Herramientas previas de Python
pip3 install setuptools_scm --break-system-packages

# 2. Escudos Globales (Disponibles cuando PIP llame a CMake internamente)
export SETUPTOOLS_SCM_PRETEND_VERSION="${TERMUX_PKG_VERSION}"
export OVERRIDE_GIT_DESCRIBE="v${TERMUX_PKG_VERSION}-0-g0000000000"

export DUCKDB_PLATFORM="android-${TERMUX_ARCH}"

export MAX_JOBS=2
export CMAKE_BUILD_PARALLEL_LEVEL=2

export CFLAGS+=" -O3 -fPIC -pipe"
export CXXFLAGS+=" -O3 -fPIC -pipe"

export CMAKE_GENERATOR="Ninja"
export CMAKE_ARGS="-DCMAKE_TOOLCHAIN_FILE=${TERMUX_CMAKE_CROSSCOMPILING_TOOLCHAIN} -DDUCKDB_PLATFORM=${DUCKDB_PLATFORM}"
}

# --- ANULACIÓN DEL COMPORTAMIENTO POR DEFECTO DE TERMUX ---
# Al devolver 0, Termux se salta su compilación C++ nativa, evitando el "Double Build"
# y el error "Exec format error" del duckdb_platform_binary original.

termux_step_configure() {
return 0
}

termux_step_make() {
return 0
}
# ----------------------------------------------------------

termux_step_make_install() {
echo "[*] Fundiendo Python-DuckDB (v${TERMUX_PKG_VERSION}) a través de PIP..."

export PYTHONPATH="$(pwd):${PYTHONPATH}"

pip3 install . \
--prefix="${TERMUX_PREFIX}" \
--no-build-isolation \
--no-deps \
--break-system-packages \
-v
}
