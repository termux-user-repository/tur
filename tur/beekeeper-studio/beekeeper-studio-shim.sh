#!@TERMUX_PREFIX@/bin/sh

GDK_BACKEND="${GDK_BACKEND:-x11}" \
ELECTRON_IS_DEV=0 \
BKS_RESOURCES_PATH="@TERMUX_PREFIX@/opt/beekeeper-studio/resources" \
exec "@TERMUX_PREFIX@/bin/electron42" "@TERMUX_PREFIX@/opt/beekeeper-studio/resources/app.asar" "$@"
