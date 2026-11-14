TERMUX_PKG_HOMEPAGE=https://github.com/ULTRAXAS/xro
TERMUX_PKG_DESCRIPTION="Xro 8.6 autonomous AI coding agent CLI by ULTRAXAS"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_LICENSE_FILE="LICENSE, NOTICE"
TERMUX_PKG_MAINTAINER="ULTRAXAS <contact@ultraxas.com>"
TERMUX_PKG_VERSION="3.0.1"
TERMUX_PKG_SRCURL="https://github.com/ULTRAXAS/xro/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=2b6217311863d822091f5bdeff5f78a3737d7a46b2753972bb9f77d97b06f9a4
TERMUX_PKG_DEPENDS="bun, opentui"
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_post_get_source() {
	# Only the CLI is packaged: drop the VS Code extension, examples,
	# evals, documentation and other monorepo bulk before installing deps.
	rm -rf docs evals apps/vscode apps/vscode-rollout apps/examples sdk/examples \
		.agents .changeset .claude .cline .clinerules .codex .github .greptile \
		.husky .kanban .vscode
	jq '.workspaces = ["sdk/packages/*", "apps/cli", "apps/cline-hub", "apps/cline-hub/src/webview"]
		| del(.scripts.prepare)' package.json > package.json.tmp
	mv package.json.tmp package.json
}

termux_step_make() {
	termux_setup_bun

	bun install
	bun --production -F './sdk/packages/*' build
	bun -F @cline/cline-hub build:webview

	# Point the OpenTUI native library resolver to the bionic-built
	# libopentui.so provided by the opentui package in $TERMUX_PREFIX/lib.
	local _opentui_js
	_opentui_js="$(grep -l 'async function resolveNativePackage' \
		node_modules/.bun/@opentui+core@*/node_modules/@opentui/core/index-*.js)"
	[[ -n "$_opentui_js" ]] || termux_error_exit "OpenTUI native resolver not found"
	sed -i \
		-e 's#if (process.platform === "linux") {#if (process.platform === "android") { return { default: (process.env.PREFIX || "'"${TERMUX_PREFIX}"'") + "/lib/libopentui.so" }; }\n  if (process.platform === "linux") {#' \
		"$_opentui_js"
	grep -q 'libopentui\.so' "$_opentui_js" ||
		termux_error_exit "Failed to patch OpenTUI native resolver"

	local -a _bun_args=(
		--target=bun
		--minify
		--outdir="$TERMUX_PKG_SRCDIR/dist-termux"
		--public-path="$TERMUX_PREFIX/lib/xro/"
		--external=@anthropic-ai/vertex-sdk
		--define 'process.env.NODE_ENV="production"'
	)
	local _p _v
	for _p in darwin-x64 darwin-arm64 win32-x64 win32-arm64 linux-x64 linux-arm64 linux-x64-musl linux-arm64-musl; do
		_bun_args+=(--external="@opentui/core-${_p}")
	done
	for _v in TELEMETRY_SERVICE_API_KEY ERROR_SERVICE_API_KEY OTEL_TELEMETRY_ENABLED \
		OTEL_LOGS_EXPORTER OTEL_METRICS_EXPORTER OTEL_TRACES_EXPORTER \
		CLINE_TRACE_SAMPLE_PERCENT CLINE_TRACE_RECORD_CONTENT \
		OTEL_EXPORTER_OTLP_PROTOCOL OTEL_EXPORTER_OTLP_ENDPOINT OTEL_EXPORTER_OTLP_HEADERS; do
		_bun_args+=(--define "process.env.${_v}=\"\"")
	done
	rm -rf dist-termux
	(cd apps/cli && bun build src/index.ts "${_bun_args[@]}")
}

termux_step_make_install() {
	install -d "$TERMUX_PREFIX/lib/xro"
	cp -a dist-termux/. "$TERMUX_PREFIX/lib/xro/"

	install -Dm644 sdk/packages/core/dist/extensions/plugin-sandbox-bootstrap.js \
		"$TERMUX_PREFIX/lib/xro/extensions/plugin-sandbox-bootstrap.js"
	install -d "$TERMUX_PREFIX/lib/xro/cline-hub"
	cp -a apps/cline-hub/dist/webview "$TERMUX_PREFIX/lib/xro/cline-hub/"
	install -Dm644 apps/cli/node_modules/@opentui/core/parser.worker.js \
		"$TERMUX_PREFIX/lib/xro/parser.worker.js"

	cat > "$TERMUX_PREFIX/bin/xro" <<-EOF
		#!${TERMUX_PREFIX}/bin/sh
		exec bun "${TERMUX_PREFIX}/lib/xro/index.js" "\$@"
	EOF
	chmod 755 "$TERMUX_PREFIX/bin/xro"
}
