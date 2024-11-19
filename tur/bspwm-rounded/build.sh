TERMUX_PKG_HOMEPAGE=https://github.com/phuhl/bspwm-rounded/tree/round_corners
TERMUX_PKG_DESCRIPTION="The received fork of BSPWM. But developed inside rounded corner workaround."
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=0.9.10
TERMUX_PKG_REVISION=6
TERMUX_PKG_SRCURL="https://github.com/phuhl/bspwm-rounded/archive/refs/tags/$TERMUX_PKG_VERSION.zip"
TERMUX_PKG_SHA256="1f2d04fa13d6bf3d19290303030ad07d4ae4bb6c7c96101120d79842e3bdca7a"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newset-tag"
TERMUX_PKG_DEPENDS="git, git-lfs, libxcb, patch, patchelf, python, python-ensurepip-wheels, python-pip, rust, rustc-dev, rustc-src, sxhkd, xcb-util, xcb-util-cursor, xcb-util-image, xcb-util-keysyms, xcb-util-renderutil, xcb-util-wm"
TERMUX_PKG_SUGGESTS="chromium, kitty, picom"
TERMUX_PKG_BUILD_DEPENDS="build-essential"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_MAKE_ARGS="prefix=/data/data/com.termux/files/usr"

termux_step_pre_configure() {
   TERMUX_LOCAL_DIR="${PREFIX}/opt/termux-local"

   mkdir --parent --verbose --mode=755 ${TERMUX_LOCAL_DIR}
   ln -sf ${TERMUX_LOCAL_DIR} ${PREFIX}/local
   ln -sf ${TERMUX_LOCAL_DIR} ${HOME}/.global_local

   mkdir --parent --verbose --mode=755 ${TERMUX_LOCAL_DIR}/bin
   echo -e "PATH+=':/data/data/com.termux/files/usr/local/bin'" > ${PREFIX}/etc/profile.d/local-path.sh

   sed -i -E '1 i\#!/data/data/com.termux/files/usr/bin/bash\' ${PREFIX}/etc/profile.d/local-path.sh
   chmod 755 ${PREFIX}/etc/profile.d/local-path.sh
   ${PREFIX}/etc/profile.d/local-path.sh
}

termux_step_post_make_install() {
   shopt -s expand_aliases
   ln -sf ${PREFIX}/bin/bspwm ${PREFIX}/local/bin/bspwm-loca

   echo -e "alias bspwm='bspwm-local'" > ${PREFIX}/etc/profile.d/local-alias.sh
   sed -i -E '1 i\#!/data/data/com.termux/files/usr/bin/bash\' ${PREFIX}/etc/profile.d/local-alias.sh
   chmod --verbose 755 ${PREFIX}/etc/profile.d/local-alias.sh
   ${PREFIX}/etc/profile.d/local-alias.sh

   $(python3 --version | sed -E "s|[[:space:]]||g;s|Python|pip|g" | cut -d '.' -f 1) install rich cli-box python-dotenv python-decouple --upgrade
   git clone --depth=1 https://github.com/ReeaoX/bsphelp.git ${HOME}/bsphelp-git

   sed -i -e $'$a\\\nalias bsphelp="${HOME}/bsphelp-git/usr/bin/bin-cmd.py"' ${PREFIX}/etc/profile.d/local-alias.sh
   ${PREFIX}/etc/profile.d/local-alias.sh
}

termux_step_post_massage() {
   BSPWM_CONFIG_DIR="${HOME}/.config/bspwm"
   SXHKD_CONFIG_DIR="${HOME}/.config/sxhkd"

   mkdir --parent --verbose --mode=755 ${BSPWM_CONFIG_DIR}
   mkdir --parent --verbose --mode=755 ${SXHKD_CONFIG_DIR}

   cp --recursive --force --verbose ${PREFIX}/share/doc/bspwm/examples/bspwmrc ${BSPWM_CONFIG_DIR}
   cp --recursive --force --verbose ${PREFIX}/share/doc/bspwm/examples/sxhkdrc ${SXHKD_CONFIG_DIR}

   chmod --verbose 755 ${BSPWM_CONFIG_DIR}/bspwmrc
   chmod --verbose 755 ${SXHKD_CONFIG_DIR}/sxhkdrc
   sed -i -E "s|/bin/sh|/data/data/com.termux/files/usr/bin/bash|g" ${BSPWM_CONFIG_DIR}/bspwmrc
}
