if [ "$TERMUX_ON_DEVICE_BUILD" = true ]; then
	export QBE="qbe"
	return
fi

bin_dir="$TERMUX_PREFIX/opt/qbe/cross/bin"
export PATH="${bin_dir}:$PATH"
export QBE="${bin_dir}/qbe"
