TERMUX_PKG_HOMEPAGE=https://openbullet.dev/
TERMUX_PKG_DESCRIPTION="Cross-platform automation suite"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="0.3.2"
TERMUX_PKG_SRCURL="https://github.com/openbullet/OpenBullet2/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=4e8c5e6aa9e70796666061ed73c6a4a0e5f012a0d8c5675c78d732db61b826f7
TERMUX_PKG_DEPENDS="aspnetcore-runtime-8.0, dotnet-host, dotnet-runtime-8.0, libsqlite"
TERMUX_PKG_BUILD_DEPENDS="aspnetcore-targeting-pack-8.0, dotnet-targeting-pack-8.0"
TERMUX_PKG_ANTI_BUILD_DEPENDS="libsqlite"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXCLUDED_ARCHES="arm"

termux_step_pre_configure() {
	termux_setup_dotnet
	termux_setup_nodejs
}

termux_step_make() {
	# https://github.com/openbullet/OpenBullet2/blob/master/Dockerfile
	mkdir -p build/wwwroot

	dotnet publish OpenBullet2.Web \
		--runtime "${DOTNET_TARGET_NAME}" \
		--configuration Release \
		-o build
	dotnet build-server shutdown

	find build -name "*.xml" -type f -delete

	pushd openbullet2-web-client
	npm install
	npm run build
	mv dist/* ../build/wwwroot
	popd

	cp -fv OpenBullet2.Web/dbip-country-lite.mmdb build/

	ls -l build
}

termux_step_make_install() {
	rm -fr "${TERMUX_PREFIX}/lib/openbullet2"
	cp -r build "${TERMUX_PREFIX}/lib/openbullet2"

	ln -fsv ../../libsqlite3.so "${TERMUX_PREFIX}/lib/openbullet2/libraries/libe_sqlite3.so"

	cat <<- EOL >"${TERMUX_PREFIX}/bin/openbullet2"
	#!${TERMUX_PREFIX}/bin/sh
	cd ${TERMUX_PREFIX}/lib/openbullet2
	exec dotnet ${TERMUX_PREFIX}/lib/openbullet2/OpenBullet2.Web.dll "\$@"
	EOL
	chmod u+x "${TERMUX_PREFIX}/bin/openbullet2"
}
