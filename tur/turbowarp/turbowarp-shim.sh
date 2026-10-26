#!@TERMUX_PREFIX@/bin/sh

# Electron calls plain "xdg-open"; Termux ships it as "xdg-utils-xdg-open",
# so put a symlink dir first in PATH.
# The GPU is blocklisted here, which leaves TurboWarp without WebGL.
PATH="@TERMUX_PREFIX@/opt/turbowarp/bin:$PATH" \
GDK_BACKEND="${GDK_BACKEND:-x11}" \
exec "@TERMUX_PREFIX@/bin/electron42" --ignore-gpu-blocklist "@TERMUX_PREFIX@/opt/turbowarp/resources/app.asar" "$@"
