TERMUX_PKG_HOMEPAGE=https://github.com/reisxd/TizenBrewInstaller
TERMUX_PKG_DESCRIPTION="Browser-based installer for TizenBrew and other Tizen TV apps"
TERMUX_PKG_LICENSE="GPL-3.0-only"
TERMUX_PKG_MAINTAINER="@zeldrisho"
TERMUX_PKG_VERSION="1.1.3"
TERMUX_PKG_SRCURL=https://github.com/reisxd/TizenBrewInstaller/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=5186b344179e63d958b172f72526651e75da8ff0aeb4a5777c0e2fe46e287786
TERMUX_PKG_DEPENDS="nodejs (>= 20) | nodejs-lts (>= 20)"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_configure() {
	termux_setup_nodejs

	local _service_dir=client/services/tizenbrew-installer-service
	local _tizen_commit=45b00106149d0c8eff74ead4a979c909dd80efd6
	# Pin the moving dependency URL while preserving lockfile integrity.
	sed -i "s|https://github.com/reisxd/tizen.js/tarball/main|https://github.com/reisxd/tizen.js/tarball/${_tizen_commit}|g" \
		"${_service_dir}/package.json" "${_service_dir}/package-lock.json"
}

termux_step_make() {
	(
		cd client/ui || exit 1
		# Upstream aliases React to Preact, which conflicts with React peer ranges.
		npm ci --force --no-audit --no-fund
		npm run build
	)
	(
		cd client/services/tizenbrew-installer-service || exit 1
		npm ci --omit=dev --ignore-scripts --no-audit --no-fund
	)
}

termux_step_make_install() {
	local _dest="${TERMUX_PREFIX}/share/${TERMUX_PKG_NAME}/client"
	local _service_dir=client/services/tizenbrew-installer-service
	local _service_dest="${_dest}/services/tizenbrew-installer-service"
	mkdir -p "${_dest}/ui" "${_service_dest}" "${TERMUX_PREFIX}/bin"
	cp -a client/ui/dist "${_dest}/ui/"
	install -m644 "${_service_dir}/index.js" "${_service_dir}/package.json" "${_service_dest}/"
	cp -a "${_service_dir}/utils" "${_service_dir}/node_modules" "${_service_dest}/"

	cat > "${TERMUX_PKG_TMPDIR}/${TERMUX_PKG_NAME}" <<-EOF
	#!${TERMUX_PREFIX}/bin/sh
	umask 077
	exec "${TERMUX_PREFIX}/bin/node" "${_service_dest}/index.js" "\$@"
	EOF
	install -Dm700 "${TERMUX_PKG_TMPDIR}/${TERMUX_PKG_NAME}" \
		"${TERMUX_PREFIX}/bin/${TERMUX_PKG_NAME}"
}
