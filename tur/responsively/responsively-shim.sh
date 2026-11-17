#!@TERMUX_PREFIX@/bin/sh

# Electron calls plain "xdg-open"; Termux ships it as "xdg-utils-xdg-open".
# electron42 isn't named "electron" at runtime, so force app.isPackaged.
PATH="@TERMUX_PREFIX@/opt/responsively/bin:$PATH" \
ELECTRON_FORCE_IS_PACKAGED=1 \
GDK_BACKEND="${GDK_BACKEND:-x11}" \
exec "@TERMUX_PREFIX@/bin/electron42" "@TERMUX_PREFIX@/opt/responsively/resources/app.asar" "$@"
