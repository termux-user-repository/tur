TERMUX_PKG_HOMEPAGE=https://github.com/jindrapetrik/jpexs-decompiler
TERMUX_PKG_DESCRIPTION="JPEXS Free Flash Decompiler"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="26.2.1"
TERMUX_PKG_REVISION=1
TERMUX_PKG_GIT_BRANCH="version${TERMUX_PKG_VERSION}"
TERMUX_PKG_SRCURL="git+https://github.com/jindrapetrik/jpexs-decompiler"
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_DEPENDS="openjdk-21, openjdk-21-x"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_HOSTBUILD=true

termux_step_host_build() {
	if [[ ! -v ANT_HOME ]]; then
		termux_download_ubuntu_packages ant
	fi
}

termux_step_pre_configure() {
	if [[ ${TERMUX_ON_DEVICE_BUILD} = true ]]; then
		export JAVA_HOME=${TERMUX__PREFIX__LIB_DIR}/jvm/java-21-openjdk
	fi
}

termux_step_make() {
	export PATH="$TERMUX_PKG_HOSTBUILD_DIR/ubuntu_packages/usr/bin:$PATH"
	ant build
}

termux_step_make_install() {
	mkdir -p $TERMUX__PREFIX/share/java
	cp -r ./dist/ $TERMUX__PREFIX/share/java/ffdec/
	cat << EOF > $TERMUX__PREFIX/bin/ffdec
#!$TERMUX_PREFIX/bin/sh

java -jar $TERMUX__PREFIX/share/java/ffdec/ffdec.jar "\$@"
EOF
	cat << EOF > $TERMUX__PREFIX/bin/ffdec-cli
#!$TERMUX_PREFIX/bin/sh

java -jar $TERMUX__PREFIX/share/java/ffdec/ffdec-cli.jar "\$@"
EOF
	chmod 755 $TERMUX__PREFIX/bin/ffdec
	chmod 755 $TERMUX__PREFIX/bin/ffdec-cli
	# Removes all Windows executables
	rm -f $TERMUX__PREFIX/share/java/ffdec/*.exe
	rm -f $TERMUX__PREFIX/share/java/ffdec/*.bat
	mkdir -p $TERMUX__PREFIX/share/applications
	cat << EOF > $TERMUX__PREFIX/share/applications/com.jpexs.decompiler.desktop
[Desktop Entry]
Type=Application
Version=26.2.1
Name=FFdec
Comment=JPEXS Free Flash Decompiler
Exec=ffdec
Icon=$TERMUX__PREFIX/share/java/ffdec/icon.png
Categories=Development;
MimeType=application/x-shockwave-flash;
EOF
	chmod +x $TERMUX__PREFIX/share/applications/com.jpexs.decompiler.desktop
}
