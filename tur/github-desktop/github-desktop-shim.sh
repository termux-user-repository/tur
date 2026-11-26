#!@TERMUX_PREFIX@/bin/sh

# Use the system git instead of the embedded one, and let git find
# git-credential-desktop (the credential helper trampoline) through PATH.
# bin/ holds an xdg-open that calls xdg-utils-xdg-open (sign-in browser).
CHROME_DESKTOP="${CHROME_DESKTOP:-github-desktop.desktop}" \
GDK_BACKEND="${GDK_BACKEND:-x11}" \
LOCAL_GIT_DIRECTORY="${LOCAL_GIT_DIRECTORY:-@TERMUX_PREFIX@}" \
PATH="@TERMUX_PREFIX@/opt/github-desktop/bin:@TERMUX_PREFIX@/opt/github-desktop/resources/app/desktop-trampoline:$PATH" \
exec "@TERMUX_PREFIX@/bin/electron42" "@TERMUX_PREFIX@/opt/github-desktop/resources/app" "$@"
