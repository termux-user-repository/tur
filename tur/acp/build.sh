TERMUX_PKG_HOMEPAGE=https://github.com/hastagaming/acp
TERMUX_PKG_DESCRIPTION="Simplify 'git add . && git commit -m && git push' into a single acp command"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@hastagaming"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SRCURL=https://github.com/hastagaming/acp/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=daeda42a3b2140eabdfe79c97ab937dc70a231078c374b41e445b8ed3b47b9f4
TERMUX_PKG_DEPENDS="git"
TERMUX_PKG_BUILD_DEPENDS=""
TERMUX_PKG_BUILD_IN_SRC=true

# NOTE: this recipe builds from source, as required by TUR review guidelines
# (TERMUX_PKG_SRCURL must point to extractable source, not a raw binary).
# A separate GitHub Actions workflow in this repository
# (.github/workflows/build-release.yml) also publishes precompiled
# per-architecture binaries on the GitHub Release page for users who want
# to install without compiling locally; see install-prebuilt.sh.

termux_step_make() {
        cd "$TERMUX_PKG_SRCDIR"
        make CC="$CC" CFLAGS="$CFLAGS -Wall -Wextra -O2 -std=c11"
}

termux_step_make_install() {
        install -Dm700 "$TERMUX_PKG_SRCDIR/acp" "$TERMUX_PREFIX/bin/acp"
        install -Dm644 "$TERMUX_PKG_SRCDIR/config/default.conf" \
                "$TERMUX_PREFIX/etc/acp/default.conf"
}
