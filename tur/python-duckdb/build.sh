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
pip3 install setuptools_scm --break-system-packages

# Inyectamos en CMakeLists.txt para evitar el error de "duckdb_platform_binary"
# y la falsa detección de versión de Git.
sed -i "/project(/a set(DUCKDB_PLATFORM \"android-${TERMUX_ARCH}\" CACHE STRING \"\" FORCE)" CMakeLists.txt
sed -i "/project(/a set(GIT_COMMIT_HASH \"0000000000\" CACHE STRING \"\" FORCE)" CMakeLists.txt
sed -i "/project(/a set(OVERRIDE_GIT_DESCRIBE \"v${TERMUX_PKG_VERSION}-0-g0000000000\" CACHE STRING \"\" FORCE)" CMakeLists.txt
}

# Desactivamos el "Double Build" (evitamos que Termux compile C++ antes que PIP)
termux_step_configure() {
return 0
}
termux_step_make() {
return 0
}

termux_step_make_install() {
export SETUPTOOLS_SCM_PRETEND_VERSION="${TERMUX_PKG_VERSION}"

# En lugar de usar una variable de toolchain que no existe, pasamos directamente
# los compiladores nativos cruzados que Termux ya nos proporciona globalmente ($CC y $CXX)
export CMAKE_ARGS="-DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX}"
export EXTRA_CMAKE_VARIABLES="${CMAKE_ARGS}"

# Limitamos a 2 hilos para evitar que GitHub Actions muera por falta de RAM (OOM)
export MAX_JOBS=2
export CMAKE_BUILD_PARALLEL_LEVEL=2

export CFLAGS+=" -O3 -fPIC -pipe"
export CXXFLAGS+=" -O3 -fPIC -pipe"

# DuckDB es un monorepo. El código de Python está dentro de esta subcarpeta.
cd "${TERMUX_PKG_SRCDIR}/tools/pythonpkg" || exit 1

echo "[*] Fundiendo DuckDB (v${TERMUX_PKG_VERSION}) a través de PIP..."

pip3 install . \
--prefix="${TERMUX_PREFIX}" \
--no-build-isolation \
--no-deps \
--break-system-packages \
-v
}
