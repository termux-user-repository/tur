TERMUX_PKG_HOMEPAGE="https://officecli.ai"
TERMUX_PKG_DESCRIPTION="CLI for reading and writing Office documents (.docx, .xlsx, .pptx) via a document DOM API"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.0.158"
TERMUX_PKG_SRCURL="https://github.com/iOfficeAI/OfficeCLI/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=5a5e7c3b84384e5db6519f0db4946f58aacb7359ff031ea52c127bbe1e7f0bc9
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_DOTNET_VERSION=10.0
TERMUX_PKG_DEPENDS="dotnet-host, dotnet-runtime-10.0"
TERMUX_PKG_BUILD_DEPENDS="dotnet-targeting-pack-10.0"
TERMUX_PKG_EXCLUDED_ARCHES="arm"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_dotnet
}

termux_step_make() {
	dotnet publish src/officecli/officecli.csproj \
		--framework "net${TERMUX_DOTNET_VERSION}" \
		--runtime "$DOTNET_TARGET_NAME" \
		--output "$TERMUX_PKG_BUILDDIR/build" \
		--no-self-contained \
		--configuration Release \
		-p:PublishTrimmed=false \
		-p:PublishSingleFile=false \
		-p:RunAnalyzers=false \
		-p:AssemblyVersion="${TERMUX_PKG_VERSION}" \
		-p:FileVersion="${TERMUX_PKG_VERSION}" \
		-p:InformationalVersion="${TERMUX_PKG_VERSION}" \
		-p:Version="${TERMUX_PKG_VERSION}"

	dotnet build-server shutdown
	termux_dotnet_kill
}

termux_step_make_install() {
	rm -rf "${TERMUX_PREFIX}/lib/${TERMUX_PKG_NAME}"
	mkdir -p "${TERMUX_PREFIX}/lib/${TERMUX_PKG_NAME}"
	cp -r "${TERMUX_PKG_BUILDDIR}/build"/* "${TERMUX_PREFIX}/lib/${TERMUX_PKG_NAME}/"

	mkdir -p "${TERMUX_PREFIX}/bin"
	ln -sf "${TERMUX_PREFIX}/lib/${TERMUX_PKG_NAME}/officecli" "${TERMUX_PREFIX}/bin/officecli"

	# Remove debug files
	rm -f "${TERMUX_PREFIX}/lib/${TERMUX_PKG_NAME}"/*.pdb
}
