TERMUX_PKG_HOMEPAGE=https://github.com/crenoxhq/crenox
TERMUX_PKG_DESCRIPTION="Statically compiled, zero-dependency Git pre-commit secret detector"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@KhaledHani"
TERMUX_PKG_VERSION="2.1.0"
TERMUX_PKG_SRCURL=https://github.com/crenoxhq/crenox/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
# crenox:ignore
TERMUX_PKG_SHA256=ac52eceda4492e5f404527ec199bc7960cdffd0edabffedd842fc18ad4f2818d
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_golang

	cd "$TERMUX_PKG_SRCDIR"

	# Build with standard Go release optimizations and inject version metadata
	go build -trimpath \
		-ldflags "-s -w -X github.com/crenoxhq/crenox/v2/pkg/version.Version=${TERMUX_PKG_VERSION}" \
		-o crenox ./cmd/crenox
}

termux_step_make_install() {
	# Install the binary to the Termux system bin prefix
	install -Dm700 "$TERMUX_PKG_SRCDIR/crenox" "$TERMUX_PREFIX"/bin/crenox
}
