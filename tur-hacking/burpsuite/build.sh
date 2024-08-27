TERMUX_PKG_HOMEPAGE="https://portswigger.net/burp/"
TERMUX_PKG_DESCRIPTION="An integrated platform for performing security testing of web applications (community edition)"
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
	rm -rf "$install_prefix"
	mkdir -p "$install_prefix"
	termux_download "https://portswigger-cdn.net/burp/releases/download?product=community&version=$TERMUX_PKG_VERSION&type=Jar" "$install_prefix/$TERMUX_PKG_NAME.jar" fba41c582be811b47f35be3f76aa9bfd4e9afbd84350bb7c97c99ab06e2ad556
	cat <<- EOF > $TERMUX_PREFIX/bin/$TERMUX_PKG_NAME
		#!$TERMUX_PREFIX/bin/env sh

		exec \$JAVA_HOME/bin/java --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.desktop/javax.swing=ALL-UNNAMED -jar $install_prefix/$TERMUX_PKG_NAME.jar --disable-auto-update "\$@"
	EOF
	chmod +x $TERMUX_PREFIX/bin/$TERMUX_PKG_NAME
	install -Dm644 -t "${TERMUX_PREFIX}/share/applications" "${TERMUX_PKG_BUILDER_DIR}/$TERMUX_PKG_NAME.desktop"
	mkdir -p "$TERMUX_PREFIX/share/pixmaps"
	unzip -p "$install_prefix/$TERMUX_PKG_NAME.jar" resources/Media/icon64community.png > "$TERMUX_PREFIX/share/pixmaps/$TERMUX_PKG_NAME.png"
	cp -f $TERMUX_PKG_BUILDER_DIR/LICENSE $TERMUX_PKG_SRCDIR
}
