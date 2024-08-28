TERMUX_PKG_HOMEPAGE="https://portswigger.net/burp/"
TERMUX_PKG_DESCRIPTION="An integrated platform for performing security testing of web applications (professional edition)"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE=LICENSE
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2023.12.1.5
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_DEPENDS="openjdk-17, openjdk-17-x"
TERMUX_PKG_ANTI_BUILD_DEPENDS="openjdk-17, openjdk-17-x"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	local install_prefix="$TERMUX_PREFIX/share/$TERMUX_PKG_NAME"
	cat <<- EOF > $TERMUX_PREFIX/bin/$TERMUX_PKG_NAME
		#!$TERMUX_PREFIX/bin/env sh

		exec \$JAVA_HOME/bin/java --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.desktop/javax.swing=ALL-UNNAMED -jar $install_prefix/$TERMUX_PKG_NAME.jar --disable-auto-update "\$@"
	EOF
	chmod +x $TERMUX_PREFIX/bin/$TERMUX_PKG_NAME
	install -Dm644 -t "${TERMUX_PREFIX}/share/applications" "${TERMUX_PKG_BUILDER_DIR}/$TERMUX_PKG_NAME.desktop"
	cp -f $TERMUX_PKG_BUILDER_DIR/LICENSE $TERMUX_PKG_SRCDIR
}

termux_step_create_debscripts() {
	local install_prefix="$TERMUX_PREFIX/share/$TERMUX_PKG_NAME"
	cat <<- EOF > ./postinst
		#!$TERMUX_PREFIX/bin/env sh

		mkdir -p "$install_prefix"
		curl -L -o "$install_prefix/$TERMUX_PKG_NAME.jar" "https://portswigger-cdn.net/burp/releases/download?product=pro&version=$TERMUX_PKG_VERSION&type=Jar"
		if [ "$(sha256sum "$install_prefix/$TERMUX_PKG_NAME.jar" | cut -d' ' -f1)" = 02e338b386436fa39554d368c205ea0d59926f9c56c77b94286fedc1feaf88b2 ]; then
			exit 1
		fi
		mkdir -p "$TERMUX_PREFIX/share/pixmaps"
		unzip -p "$install_prefix/$TERMUX_PKG_NAME.jar" resources/Media/icon64pro.png > "$TERMUX_PREFIX/share/pixmaps/$TERMUX_PKG_NAME.png"
	EOF
	cat <<- EOF > ./prerm
		#!$TERMUX_PREFIX/bin/env sh

		rm -rf "$install_prefix"
		rm -f "$TERMUX_PREFIX/share/pixmaps/$TERMUX_PKG_NAME.png"
	EOF
}
