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

# Inyección en C++ para evitar el Exec format error y los fallos de GIT
sed -i "/project(/a set(DUCKDB_PLATFORM \"android-${TERMUX_ARCH}\" CACHE STRING \"\" FORCE)" CMakeLists.txt
sed -i "/project(/a set(GIT_COMMIT_HASH \"0000000000\" CACHE STRING \"\" FORCE)" CMakeLists.txt
sed -i "/project(/a set(OVERRIDE_GIT_DESCRIBE \"v${TERMUX_PKG_VERSION}-0-g0000000000\" CACHE STRING \"\" FORCE)" CMakeLists.txt
}

# Dejamos que Termux configure, pero anulamos la fase 'make' para evitar doble compilación masiva
termux_step_make() {
return 0
}

termux_step_make_install() {
export SETUPTOOLS_SCM_PRETEND_VERSION="${TERMUX_PKG_VERSION}"
export DUCKDB_PLATFORM="android-${TERMUX_ARCH}"

# Extirpamos la variable fantasma que provocaba el Unbound Variable.
# Solo pasamos la plataforma extra. PIP y Termux se encargarán del compilador cruzado.
export EXTRA_CMAKE_VARIABLES="-DDUCKDB_PLATFORM=${DUCKDB_PLATFORM}"
export CMAKE_ARGS="-DDUCKDB_PLATFORM=${DUCKDB_PLATFORM}"

export MAX_JOBS=2
export CMAKE_BUILD_PARALLEL_LEVEL=2

export CFLAGS+=" -O3 -fPIC -pipe"
export CXXFLAGS+=" -O3 -fPIC -pipe"

echo "[*] Entrando en la forja de DuckDB (v${TERMUX_PKG_VERSION})..."

export PYTHONPATH="$(pwd):${PYTHONPATH:-}"

cd "${TERMUX_PKG_SRCDIR}" || exit 1

pip3 install . \
--prefix="${TERMUX_PREFIX}" \
--no-build-isolation \
--no-deps \
--break-system-packages \
-v
}
