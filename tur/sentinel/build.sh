TERMUX_PKG_HOMEPAGE=https://github.com/sentinel-cli/sentinel
TERMUX_PKG_DESCRIPTION="Statically compiled, zero-dependency Git pre-commit secret detector"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@KhaledHani"
TERMUX_PKG_VERSION="2.0.6"
TERMUX_PKG_SRCURL=https://github.com/sentinel-cli/sentinel/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
# sentinel:ignore
TERMUX_PKG_SHA256=afbef5b7f497bfbe8e913f7675f613294f7e9074fa5a9dba8c7da7729476ac8b
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
