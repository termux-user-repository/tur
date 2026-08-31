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

# Desactivamos el doble build de Termux. PIP gestionará todo.
termux_step_configure() {
return 0
}

termux_step_make() {
return 0
}

termux_step_make_install() {
# 1. Instalamos las herramientas vitales de construcción de DuckDB (PyPI)
pip3 install setuptools_scm scikit-build-core nanobind --break-system-packages

# 2. Fijamos la versión para que no busque repositorios Git
export SETUPTOOLS_SCM_PRETEND_VERSION="${TERMUX_PKG_VERSION}"

# 3. Pasamos la plataforma a CMake limpiamente a través de CMAKE_ARGS para evitar el "Exec format error"
export CMAKE_ARGS="-DDUCKDB_PLATFORM=android-${TERMUX_ARCH}"

# 4. Limitamos hilos para no sufrir un Out Of Memory (OOM) en GitHub Actions
export MAX_JOBS=2
export CMAKE_BUILD_PARALLEL_LEVEL=2

export CFLAGS+=" -O3 -fPIC -pipe"
export CXXFLAGS+=" -O3 -fPIC -pipe"

echo "[*] Compilando DuckDB (v${TERMUX_PKG_VERSION}) de forma limpia desde PyPI..."

# 5. Instalamos desde el directorio raíz nativo
pip3 install . \
--prefix="${TERMUX_PREFIX}" \
--no-build-isolation \
--no-deps \
--break-system-packages \
-v
}
