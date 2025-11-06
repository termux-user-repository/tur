TERMUX_PKG_HOMEPAGE=https://github.com/SteamRE/DepotDownloader
TERMUX_PKG_DESCRIPTION="Steam depot downloader utilizing the SteamKit2 library"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="3.4.0"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=git+https://github.com/SteamRE/DepotDownloader
TERMUX_PKG_GIT_BRANCH="DepotDownloader_${TERMUX_PKG_VERSION}"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="dotnet-host, dotnet-runtime-9.0"
TERMUX_PKG_BUILD_DEPENDS="dotnet-targeting-pack-9.0"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXCLUDED_ARCHES="arm"
TERMUX_DOTNET_VERSION=9.0
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_UPDATE_VERSION_SED_REGEXP='s/DepotDownloader_//g'

termux_step_pre_configure() {
	termux_setup_dotnet
}

termux_step_make() {
	dotnet publish DepotDownloader/DepotDownloader.csproj --configuration Release -p:UseAppHost=false -p:DebugType=embedded --no-self-contained --output out
}

termux_step_make_install() {
	ls -l out

	find out -name "*.dll" -exec chmod 0644 "{}" \;

	#Exclude LICENSE file from being copied because same thing is already added in other folder.
	rm out/LICENSE

	mkdir -p "${TERMUX_PREFIX}/lib"
	cp -r out "${TERMUX_PREFIX}/lib/${TERMUX_PKG_NAME}"

	cat <<- EOL > ${TERMUX_PREFIX}/bin/${TERMUX_PKG_NAME}
	#!${TERMUX_PREFIX}/bin/sh
	exec dotnet "${TERMUX_PREFIX}/lib/${TERMUX_PKG_NAME}/DepotDownloader.dll" "\$@"
	EOL
	chmod 0755 "${TERMUX_PREFIX}/bin/${TERMUX_PKG_NAME}"
}
