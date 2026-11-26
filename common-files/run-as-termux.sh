#!/system/bin/sh
BASE_DIR="/data/data/com.termux/files"

if [ $(id -u) = 0 ]; then
    su $(stat -c %u $BASE_DIR) "$(realpath $0)" "$@"
    exit 0
fi

export PREFIX="$BASE_DIR/usr"
export HOME="$BASE_DIR/home"
export TMPDIR="$BASE_DIR/usr/tmp"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export PATH="$PREFIX/bin:$PATH"
export TZ="UTC"
export LANG="en_US.UTF-8"
export SHELL="$PREFIX/bin/bash"

"$SHELL" "$@"
