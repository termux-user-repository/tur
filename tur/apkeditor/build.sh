TERMUX_PKG_HOMEPAGE=https://github.com/REAndroid/APKEditor
TERMUX_PKG_DESCRIPTION="Android binary resource files editor"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@Veha0001"
TERMUX_PKG_VERSION=1.4.2
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=git+https://github.com/REAndroid/APKEditor
TERMUX_PKG_DEPENDS="openjdk-21"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_GIT_BRANCH="V${TERMUX_PKG_VERSION}"

termux_step_get_source() {
	local RELEASE_JAR="https://github.com/REAndroid/APKEditor/releases/download/${TERMUX_PKG_GIT_BRANCH}/APKEditor-${TERMUX_PKG_VERSION}.jar"
	termux_download $RELEASE_JAR $TERMUX_PKG_CACHEDIR/APKEditor-${TERMUX_PKG_VERSION}.jar
}

termux_step_make_install() {
	local RAWJAR="$TERMUX_PKG_CACHEDIR/APKEditor-${TERMUX_PKG_VERSION}.jar"
	local INSTALL_PREFIX="$TERMUX_PREFIX/libexec/apkeditor/apkeditor.jar"
	install -Dm600 $RAWJAR \
		$INSTALL_PREFIX
	cat <<- EOF > $TERMUX_PREFIX/bin/apkeditor
	#!${TERMUX_PREFIX}/bin/sh
	JAVA_OPTS="-Xmx512M"
	exec java \$JAVA_OPTS -jar $INSTALL_PREFIX "\$@"
	EOF
	chmod 700 $TERMUX_PREFIX/bin/apkeditor
}
