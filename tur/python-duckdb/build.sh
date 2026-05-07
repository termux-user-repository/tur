# Archivo: tur/python-duckdb/build.sh
# ==============================================================================
# 🛡️ PICO OS - BLUEPRINT DE COMPILACIÓN (PYTHON-DUCKDB)
# ==============================================================================

TERMUX_PKG_HOMEPAGE="https://duckdb.org/"
TERMUX_PKG_DESCRIPTION="DuckDB is an in-process SQL OLAP database management system"
TERMUX_PKG_LICENSE="MIT"

# 🎖️ AQUÍ ESTÁ TU MÉRITO:
TERMUX_PKG_MAINTAINER="@pablobp10"
TERMUX_PKG_VERSION="1.5.2"

# Apuntamos directamente al código fuente en crudo
TERMUX_PKG_SRCURL="https://pypi.io/packages/source/d/duckdb/duckdb-${TERMUX_PKG_VERSION}.tar.gz"
# El hash de integridad (Lo calcularemos en el siguiente paso)
TERMUX_PKG_SHA256="638da0d5102b6cb6f7d47f83d0600708ac1d3cb46c5e9aaabc845f9ba4d69246" 

# Dependencias necesarias en el móvil de quien lo instale
TERMUX_PKG_DEPENDS="python, libc++, libexecinfo"
# Herramientas necesarias para los bots que van a compilarlo
TERMUX_PKG_BUILD_DEPENDS="cmake, ninja, python-pip, python-setuptools-scm, python-pybind11"

# Obligamos a construir en la misma carpeta fuente para evitar bugs de CMake
TERMUX_PKG_BUILD_IN_SRC=true

# ------------------------------------------------------------------------------
# 🛡️ PROTOCOLO MODO INMORTAL (INYECCIÓN PRE-COMPILACIÓN)
# ------------------------------------------------------------------------------
termux_step_pre_configure() {
    termux_setup_ninja
    termux_setup_cmake
    
    # 1. Estrangulamiento de hilos para sobrevivir a la RAM (Como pediste)
    export CMAKE_BUILD_PARALLEL_LEVEL=1 
    
    # 2. Inyección del enlazador para Android (Bionic libc)
    export LDFLAGS+=" -lexecinfo"
    export CPPFLAGS+=" -I${TERMUX_PREFIX}/include"
    
    # 3. Anulamos variables corruptas que confunden a CMake en el CI
    unset CC
    unset CXX
    
    # 4. Obligamos al empaquetador a usar las herramientas nativas del servidor
    export SKBUILD_CMAKE_EXECUTABLE=$(command -v cmake)
    export SKBUILD_NINJA_EXECUTABLE=$(command -v ninja)
}

# ------------------------------------------------------------------------------
# 💥 ASALTO FRONTAL (BYPASS PEP-517)
# ------------------------------------------------------------------------------
termux_step_make_install() {
    # Añadimos el directorio actual al path para el build-backend de Python
    export PYTHONPATH=$(pwd):$PYTHONPATH
    
    # Disparamos el asalto: --no-build-isolation evita descargar un CMake roto
    # y --no-deps evita bucles de compilación cruzada.
    pip install . \
        --no-build-isolation \
        --no-deps \
        --prefix="${TERMUX_PREFIX}" \
        -v
}
