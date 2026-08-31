TERMUX_PKG_HOMEPAGE="https://duckdb.org/"
TERMUX_PKG_DESCRIPTION="DuckDB is an in-process SQL OLAP database management system"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@pablobp10"

TERMUX_PKG_VERSION="1.5.5"
# PyPI es la única fuente válida porque empaqueta C++ y Python juntos (sin submodules)
TERMUX_PKG_SRCURL="https://files.pythonhosted.org/packages/source/d/duckdb/duckdb-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="72f33ee57ca7595b23957671a2cc7f7fe2be0ecc2d68f63abedcfcaa3a5c1238"

TERMUX_PKG_DEPENDS="python, libc++"
TERMUX_PKG_BUILD_DEPENDS="cmake, ninja"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
# ¡LA CLAVE! Al usar --no-build-isolation, debemos instalar las herramientas
# que el backend de PyPI exige en su pyproject.toml para arrancar:
pip3 install setuptools_scm scikit-build-core nanobind --break-system-packages
}

# Desactivamos las fases automáticas de C++ para que no haya Double-Build
termux_step_configure() {
return 0
}
termux_step_make() {
return 0
}

termux_step_make_install() {
# 1. Forzamos a Termux a generar la variable del Toolchain (evita el "unbound variable")
termux_setup_cmake

export SETUPTOOLS_SCM_PRETEND_VERSION="${TERMUX_PKG_VERSION}"
export DUCKDB_PLATFORM="android-${TERMUX_ARCH}"

# 2. scikit-build-core enviará estos argumentos directamente a CMake de forma segura
export CMAKE_ARGS="-DCMAKE_TOOLCHAIN_FILE=${TERMUX_CMAKE_CROSSCOMPILING_TOOLCHAIN} -DDUCKDB_PLATFORM=${DUCKDB_PLATFORM}"

export MAX_JOBS=2
export CMAKE_BUILD_PARALLEL_LEVEL=2

export CFLAGS+=" -O3 -fPIC -pipe"
export CXXFLAGS+=" -O3 -fPIC -pipe"

echo "[*] Fundiendo DuckDB (v${TERMUX_PKG_VERSION}) nativo desde PyPI..."

# No hace falta "cd" porque PyPI extrae todo en la raíz del SRC
pip3 install . \
--prefix="${TERMUX_PREFIX}" \
--no-build-isolation \
--no-deps \
--break-system-packages \
-v
}
