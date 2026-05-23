TERMUX_PKG_HOMEPAGE=https://github.com/termux-user-repository/tur
TERMUX_PKG_DESCRIPTION="Mouse OS - A lightweight custom XFCE4 VNC desktop environment"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="Termux Developer"
TERMUX_PKG_VERSION=1.0.0
TERMUX_PKG_DEPENDS="x11-repo, tigervnc, xfce4, xfce4-goodies, pulseaudio"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
mkdir -p "$TERMUX_PREFIX/bin"
cat << 'INNER_EOF' > "$TERMUX_PREFIX/bin/mouseos"
#!/data/data/com.termux/files/usr/bin/bash
echo "Initializing Mouse OS..."
vncserver :1
INNER_EOF
chmod +x "$TERMUX_PREFIX/bin/mouseos"
}
