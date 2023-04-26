. "$TERMUX_PREFIX/opt/qbe/cross/setup.sh"
. "$TERMUX_PREFIX/opt/harec/cross/setup.sh"

if [ "$TERMUX_ON_DEVICE_BUILD" = true ]; then
	export HARE="hare"
	return
fi

bin_dir="$TERMUX_PREFIX/opt/hare/cross/bin"
export PATH="${bin_dir}:$PATH"
export HARE="${bin_dir}/hare"
