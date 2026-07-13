TERMUX_PKG_HOMEPAGE=https://github.com/sentinel-cli/sentinel
TERMUX_PKG_DESCRIPTION="Statically compiled, zero-dependency Git pre-commit secret detector"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@KhaledHani"
TERMUX_PKG_VERSION="2.0.7"
TERMUX_PKG_SRCURL=https://github.com/sentinel-cli/sentinel/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
# sentinel:ignore
TERMUX_PKG_SHA256=e5e91c8dee574d6702370c67bc4c7f39dd928f7c76be25b31932b24fbb8812b2
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_golang

	cd "$TERMUX_PKG_SRCDIR"

	# Build with standard Go release optimizations and inject version metadata
	go build -trimpath \
		-ldflags "-s -w -X github.com/sentinel-cli/sentinel/v2/pkg/version.Version=${TERMUX_PKG_VERSION}" \
		-o sentinel ./cmd/sentinel
}

termux_step_make_install() {
	# Install the binary to the Termux system bin prefix
	install -Dm700 "$TERMUX_PKG_SRCDIR/sentinel" "$TERMUX_PREFIX"/bin/sentinel
}
