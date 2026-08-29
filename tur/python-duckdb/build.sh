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

TERMUX_PKG_SRCURL="https://pypi.io/packages/source/d/duckdb/duckdb-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="638da0d5102b6cb6f7d47f83d0600708ac1d3cb46c5e9aaabc845f9ba4d69246"

TERMUX_PKG_DEPENDS="python, libc++, libexecinfo"
TERMUX_PKG_BUILD_DEPENDS="cmake, ninja, python-pip, python-setuptools-scm, python-pybind11"

TERMUX_PKG_BUILD_IN_SRC=true

# ------------------------------------------------------------------------------
# 🛡️ PROTOCOLO PRE-COMPILACIÓN
# ------------------------------------------------------------------------------
termux_step_pre_configure() {
	termux_setup_ninja
	termux_setup_cmake
	
	# Aseguramos que se instalan las herramientas de compilación de Python cruzadas
	termux_setup_python_crossenv
}

# ------------------------------------------------------------------------------
# 💥 ASALTO FRONTAL: MODO TURBO + CROSS COMPILATION
# ------------------------------------------------------------------------------
termux_step_make_install() {
	# 1. PARALELISMO MASIVO (Usamos los hilos que asigne el servidor de TUR)
	export CMAKE_BUILD_PARALLEL_LEVEL=$TERMUX_MAKE_PROCESSES
	export MAX_JOBS=$TERMUX_MAKE_PROCESSES

	# 2. MOTOR NINJA
	export CMAKE_GENERATOR="Ninja"
	export SKBUILD_CMAKE_GENERATOR="Ninja"

	# 3. EL SECRETO DE LA COMPILACIÓN CRUZADA
	# En lugar de borrar CC/CXX, le decimos a CMake exactamente dónde está el mapa 
	# de Android usando el Toolchain autogenerado por Termux.
	export CMAKE_ARGS="-DCMAKE_TOOLCHAIN_FILE=${TERMUX_CMAKE_CROSSCOMPILING_TOOLCHAIN}"
	export SKBUILD_CMAKE_ARGS="-DCMAKE_TOOLCHAIN_FILE=${TERMUX_CMAKE_CROSSCOMPILING_TOOLCHAIN}"

	# 4. ENLAZADOR Y OPTIMIZACIONES AGRESIVAS
	export LDFLAGS+=" -lexecinfo"
	export CFLAGS+=" -O3 -fPIC -pipe"
	export CXXFLAGS+=" -O3 -fPIC -pipe"

	echo "[*] Fundiendo DuckDB (v${TERMUX_PKG_VERSION}) con $MAX_JOBS hilos y Ninja en modo Cruzado..."

	# 5. INSTALACIÓN AISLADA
	export PYTHONPATH=$(pwd):$PYTHONPATH
	
	pip3 install . \
		--prefix="${TERMUX_PREFIX}" \
		--no-build-isolation \
		--no-deps \
		-v
}
