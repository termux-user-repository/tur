TERMUX_PKG_HOMEPAGE=https://github.com/termux-user-repository/tur
TERMUX_PKG_DESCRIPTION="Phone Uploader - Package transfer and local server sync tool"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="Termux Developer"
TERMUX_PKG_VERSION=1.0.0
TERMUX_PKG_DEPENDS="python"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
mkdir -p "$TERMUX_PREFIX/bin"
cat << 'INNER_EOF' > "$TERMUX_PREFIX/bin/phone-uploader"
#!/data/data/com.termux/files/usr/bin/bash
echo "Launching Phone Uploader..."
python -m http.server 8080
INNER_EOF
chmod +x "$TERMUX_PREFIX/bin/phone-uploader"
}
