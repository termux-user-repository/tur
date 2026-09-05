TERMUX_PKG_HOMEPAGE="https://ece.uwaterloo.ca/~aplevich/Circuit_macros/"
TERMUX_PKG_DESCRIPTION="M4 macros for drawing electric circuits and other diagrams"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="Licence.txt"
TERMUX_PKG_MAINTAINER="Husni Muhammad <mhdhusni2k03@gmail.com>"
TERMUX_PKG_VERSION="11.1"

TERMUX_PKG_SRCURL="https://mirrors.ctan.org/graphics/circuit_macros.zip"
TERMUX_PKG_SHA256="453ca7505f399f1e32e2188790f99c7d8fbbb3bb665186669cac655eb697c469"

TERMUX_PKG_DEPENDS="m4,dpic"

TERMUX_PKG_BUILD_IN_SRC=true

termux_step_configure() {
    :
}

termux_step_make() {
    :
}

termux_step_make_install() {
    local dest="$TERMUX_PREFIX/share/circuit-macros"

    mkdir -p "$dest"

    cp -a ./* "$dest/"

    # make the main macro files easily discoverable in standard Termux share directory.
    mkdir -p "$TERMUX_PREFIX/share/m4"

    for f in *.m4; do
        [ -f "$f" ] || continue
        ln -sf "../circuit-macros/$f" \
            "$TERMUX_PREFIX/share/m4/$f"
    done
}
