if [ "$TERMUX_ON_DEVICE_BUILD" = true ]; then
	export HAREC="harec"
	return
fi

bin_dir="$TERMUX_PREFIX/opt/harec/cross/bin"
export PATH="${bin_dir}:$PATH"
export HAREC="${bin_dir}/harec"
