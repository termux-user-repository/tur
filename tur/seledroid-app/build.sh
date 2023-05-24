TERMUX_PKG_HOMEPAGE=https://github.com/luanon404/android-webdrivers
TERMUX_PKG_DESCRIPTION="Chromium-based android webdriver application used by seledroid."
TERMUX_PKG_LICENSE="Unlicense"
TERMUX_PKG_MAINTAINER="@nacho00112"
TERMUX_PKG_VERSION=1.1.1
TERMUX_PKG_SRCURL=https://github.com/nacho00112/android-webdrivers/archive/refs/heads/main.zip
TERMUX_PKG_SHA256=0c75217771b2d04b5a23a3e1103ccede229cac8ae251ca32e34f5efd1f68138d
TERMUX_PKG_BUILD_IN_SRC=true

SELEDROID_APP_SHARED=$TERMUX_PREFIX/share/seledroid-app
SELEDROID_APK=$SELEDROID_APP_SHARED/Chromium-$TERMUX_PKG_VERSION.apk

termux_step_make_install() {
	local SHARED=$SELEDROID_APP_SHARED
	mkdir -p $SHARED
	cp Apk-Android-WebDrivers/Chromium/Chromium-$TERMUX_PKG_VERSION.apk $SELEDROID_APK
	echo $TERMUX_PKG_VERSION > VERSION
	cp VERSION $SHARED
	INSTALL_SELEDROID_APP_FILE=$TERMUX_PKG_BUILDER_DIR/install-seledroid-app
	chmod +x $INSTALL_SELEDROID_APP_FILE
	cp $INSTALL_SELEDROID_APP_FILE $TERMUX_PREFIX/bin
}

termux_step_create_debscripts() {
	echo '
echo "INFO: You can install the SeleDroid APP by executing \`install-seledroid-app\`"
echo "INFO: Also you can get the APK from '"$SELEDROID_APK"'"
' \
	> postinst
}
