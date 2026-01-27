TERMUX_PKG_HOMEPAGE=https://github.com/djunekz/tdoc
TERMUX_PKG_DESCRIPTION="TDOC - Diagnostic and repair utility for Termux environment"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@djunekz"
TERMUX_PKG_VERSION=1.0.5

TERMUX_PKG_SRCURL=https://github.com/djunekz/tdoc/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=81ebc15bfefe7ab78f31fd919b2d2432ca83208b341ca77935daf3b051091990

TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_DEPENDS="bash, coreutils, curl, git, gnupg, termux-tools"

termux_step_make_install() {
	install -d "$TERMUX_PREFIX/lib/tdoc"

	cp -r \
		"$TERMUX_PKG_SRCDIR/core" \
		"$TERMUX_PKG_SRCDIR/modules" \
		"$TERMUX_PKG_SRCDIR/data" \
		"$TERMUX_PKG_SRCDIR/tdoc" \
		"$TERMUX_PREFIX/lib/tdoc/"

	install -Dm755 \
		"$TERMUX_PREFIX/lib/tdoc/tdoc" \
		"$TERMUX_PREFIX/bin/tdoc"

	if [[ -f "$TERMUX_PKG_SRCDIR/man/tdoc.1" ]]; then
		install -Dm644 \
			"$TERMUX_PKG_SRCDIR/man/tdoc.1" \
			"$TERMUX_PREFIX/share/man/man1/tdoc.1"
	fi

	install -Dm644 \
		"$TERMUX_PKG_SRCDIR/README.md" \
		"$TERMUX_PREFIX/share/doc/tdoc/README.md"

	install -Dm644 \
		"$TERMUX_PKG_SRCDIR/LICENSE" \
		"$TERMUX_PREFIX/share/licenses/tdoc/LICENSE"

	install -d "$TERMUX_PREFIX/var/lib/tdoc"
}
