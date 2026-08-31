TERMUX_PKG_HOMEPAGE="https://duckdb.org/"
TERMUX_PKG_DESCRIPTION="DuckDB is an in-process SQL OLAP database management system"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@pablobp10"

TERMUX_PKG_VERSION="1.5.5"
# CAMBIO ESTRUCTURAL: Descargamos el paquete preparado y optimizado de PyPI
TERMUX_PKG_SRCURL="https://files.pythonhosted.org/packages/source/d/duckdb/duckdb-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="72f33ee57ca7595b23957671a2cc7f7fe2be0ecc2d68f63abedcfcaa3a5c1238"

TERMUX_PKG_DEPENDS="python, libc++"
TERMUX_PKG_BUILD_DEPENDS="cmake, ninja, pybind11"
TERMUX_PKG_BUILD_IN_SRC=true

# Desactivamos el "Double Build". Termux solo mirará; PIP hará todo el trabajo.
termux_step_configure() {
return 0
}
termux_step_make() {
return 0
}

termux_step_make_install() {
export DUCKDB_PLATFORM="android-${TERMUX_ARCH}"

# Limitamos hilos para evitar colapso de RAM en GitHub Actions
export MAX_JOBS=2
export CMAKE_BUILD_PARALLEL_LEVEL=2

export CFLAGS+=" -O3 -fPIC -pipe"
export CXXFLAGS+=" -O3 -fPIC -pipe"

echo "[*] Fundiendo DuckDB (v${TERMUX_PKG_VERSION}) nativo desde PyPI..."

export PYTHONPATH="$(pwd):${PYTHONPATH:-}"

# Instalación directa y limpia
pip3 install . \
--prefix="${TERMUX_PREFIX}" \
--no-build-isolation \
--no-deps \
--break-system-packages \
-v
}
