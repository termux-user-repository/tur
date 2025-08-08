TERMUX_PKG_HOMEPAGE=https://github.com/Stirling-Tools/Stirling-PDF
TERMUX_PKG_DESCRIPTION="Locally hosted web application that allows you to perform various operations on PDF files"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.28.3
TERMUX_PKG_SRCURL=https://github.com/Stirling-Tools/Stirling-PDF/releases/download/v${TERMUX_PKG_VERSION}/Stirling-PDF-with-login.jar
TERMUX_PKG_SHA256=ce9c206f9724018608efed774fdbce8de811636557aaf345b116b44f0191fdea
TERMUX_PKG_DEPENDS="ghostscript, jbig2enc, jbig2enc-static, opencv, opencv-python, openjdk-17, openjdk-17-x, pngquant, python, python-cryptography, qpdf, tesseract, unpaper, xdg-utils"
TERMUX_PKG_ANTI_BUILD_DEPENDS="ghostscript, jbig2enc, jbig2enc-static, opencv, opencv-python, openjdk-17, openjdk-17-x, pngquant, python, python-cryptography, qpdf, tesseract, unpaper, xdg-utils"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true	
TERMUX_PKG_PYTHON_TARGET_DEPS="ocrmypdf"


termux_step_get_source() {
	mkdir -p $TERMUX_PKG_SRCDIR
	termux_download https://raw.githubusercontent.com/Stirling-Tools/Stirling-PDF/main/LICENSE $TERMUX_PKG_SRCDIR/LICENSE 611928245256338754a280bae34bb85b9d7666b9d0f33538a6d2d15f3bca2796
	local install_prefix="$TERMUX_PREFIX/share/$TERMUX_PKG_NAME"
	rm -rf "$install_prefix"
	mkdir -p "$install_prefix"
	termux_download $TERMUX_PKG_SRCURL \
		"$install_prefix/$TERMUX_PKG_NAME-$TERMUX_PKG_VERSION.jar" \
		$TERMUX_PKG_SHA256
}

termux_step_make() {
	local installed_jar="$TERMUX_PREFIX/share/$TERMUX_PKG_NAME/$TERMUX_PKG_NAME-$TERMUX_PKG_VERSION.jar"

	# patch the setting file tessdataDir
	local setting_file="BOOT-INF/classes/settings.yml.template"
	mkdir -p "$(dirname $setting_file)"
	unzip -p "$installed_jar" "$setting_file" > "$setting_file"
	sed -i "s|/usr/|$TERMUX_PREFIX/|g" "$setting_file"
	zip -ur "$installed_jar" "$setting_file"

	# executable files
	local runtime_dir="$TERMUX_PREFIX/var/lib/stirling-pdf"
	cat <<- EOF > $TERMUX_PREFIX/bin/$TERMUX_PKG_NAME
		#!$TERMUX_PREFIX/bin/env sh

		cd "$runtime_dir"
		exec \$JAVA_HOME/bin/java --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.desktop/javax.swing=ALL-UNNAMED -jar $installed_jar "\$@"
	EOF
	cat <<- EOF > $TERMUX_PREFIX/bin/$TERMUX_PKG_NAME-webui
		#!$TERMUX_PREFIX/bin/env sh

		url_opened=false
		cd "$runtime_dir"

		exec \$JAVA_HOME/bin/java --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.desktop/javax.swing=ALL-UNNAMED -jar $installed_jar "\$@" | while IFS= read -r line; do
			echo "\$line"
			if echo "\$line" | grep -qE 'http://localhost:[0-9]+'; then
				url=\$(echo "\$line" | grep -oE 'http://localhost:[0-9]+')
				if [ "\$url_opened" = false ]; then
					xdg-utils-xdg-open "\$url"
					url_opened=true
				fi
			fi
		done
	EOF
	chmod +x $TERMUX_PREFIX/bin/$TERMUX_PKG_NAME
	chmod +x $TERMUX_PREFIX/bin/$TERMUX_PKG_NAME-webui

	# other misc files
	install -Dm644 -t "${TERMUX_PREFIX}/share/applications" "${TERMUX_PKG_BUILDER_DIR}/$TERMUX_PKG_NAME.desktop"
	mkdir -p "$TERMUX_PREFIX/share/pixmaps"
	unzip -p "$installed_jar" BOOT-INF/classes/static/favicon.svg > "$TERMUX_PREFIX/share/pixmaps/$TERMUX_PKG_NAME.svg"
}

termux_step_create_debscripts() {
	local runtime_dir="$TERMUX_PREFIX/var/lib/stirling-pdf"
	cat <<- EOF > ./postinst
		#!${TERMUX_PREFIX}/bin/bash

		echo "mkdir $runtime_dir"
		rm -rf "$runtime_dir"
		mkdir -p "$runtime_dir"

		echo "Installing dependencies through pip..."
		pip install --upgrade ${TERMUX_PKG_PYTHON_TARGET_DEPS//, / }
	EOF
	# Pre-rm script to cleanup runtime-generated files.
	cat <<- PRERM_EOF > ./prerm
		#!$TERMUX_PREFIX/bin/sh
		echo "Deleting all files under $runtime_dir"
		rm -Rf "$runtime_dir"
		exit 0
	PRERM_EOF
}
