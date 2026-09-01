#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
DQ_HOME="$HOME/.docker-qemu"
IMG="$DQ_HOME/alpine.img"
ISO="$DQ_HOME/alpine.iso"
ALPINE_VERSION="3.24.1"
ALPINE_BRANCH="v3.24"
ALPINE_BASE="https://dl-cdn.alpinelinux.org/alpine/${ALPINE_BRANCH}/releases/x86_64"
ALPINE_ISO_NAME="alpine-virt-${ALPINE_VERSION}-x86_64.iso"
ALPINE_URL="${ALPINE_BASE}/${ALPINE_ISO_NAME}"
ALPINE_SHA256_URL="${ALPINE_URL}.sha256"
SSH_PORT=2222

usage() {
	cat <<EOF
docker-qemu <command>

  setup     download Alpine ISO + create disk image (first run only)
  init      boot ISO once, run headless Alpine install + Docker provisioning
  start     boot the persistent image in the background
  stop      shut the VM down cleanly over SSH
  ssh       ssh into the running VM
  status    show whether the VM is running
EOF
}

require_dir() { mkdir -p "$DQ_HOME"; }

cmd_setup() {
	require_dir
	if [ ! -f "$ISO" ]; then
		echo "Downloading Alpine $ALPINE_VERSION..."
		wget -O "$ISO" "$ALPINE_URL"
		echo "Fetching Alpine's published checksum for verification..."
		wget -O "$ISO.sha256" "$ALPINE_SHA256_URL"
		# The upstream file is "<hash>  <filename>" using Alpine's own name;
		# rewrite the filename field to match our local path before checking.
		awk -v f="$ISO" '{print $1"  "f}' "$ISO.sha256" > "$ISO.sha256.local"
		sha256sum -c "$ISO.sha256.local" || {
			echo "Checksum mismatch against Alpine's published hash, aborting" >&2
			rm -f "$ISO" "$ISO.sha256" "$ISO.sha256.local"
			exit 1
		}
		rm -f "$ISO.sha256" "$ISO.sha256.local"
	fi
	if [ ! -f "$IMG" ]; then
		qemu-img create -f qcow2 "$IMG" 8G
	fi
	echo "Setup complete. Run 'docker-qemu init' next."
}

cmd_init() {
	require_dir
	if [ ! -f "$ISO" ] || [ ! -f "$IMG" ]; then
		echo "Run 'docker-qemu setup' first" >&2
		exit 1
	fi
	echo "Booting installer -- run 'setup-alpine' then inside the guest run:"
	echo "  apk add docker docker-cli-compose && rc-update add docker boot && service docker start"
	qemu-system-x86_64 \
		-machine q35 -accel tcg -m 2048 -smp 2 -cpu qemu64 \
		-netdev user,id=n1,hostfwd=tcp::${SSH_PORT}-:22 \
		-device virtio-net,netdev=n1 \
		-cdrom "$ISO" -boot d \
		-drive file="$IMG",if=virtio \
		-nographic
}

cmd_start() {
	[ -f "$IMG" ] || { echo "No image yet -- run 'docker-qemu setup' && 'docker-qemu init' first" >&2; exit 1; }
	nohup qemu-system-x86_64 \
		-machine q35 -accel tcg -m 2048 -smp 2 -cpu qemu64 \
		-netdev user,id=n1,hostfwd=tcp::${SSH_PORT}-:22 \
		-device virtio-net,netdev=n1 \
		-drive file="$IMG",if=virtio \
		-nographic \
		> "$DQ_HOME/vm.log" 2>&1 &
	echo $! > "$DQ_HOME/vm.pid"
	echo "VM starting in background (pid $(cat "$DQ_HOME/vm.pid")). Use 'docker-qemu ssh' once booted."
}

cmd_stop() {
	ssh -p "$SSH_PORT" -o StrictHostKeyChecking=no root@localhost 'poweroff' 2>/dev/null || true
	if [ -f "$DQ_HOME/vm.pid" ]; then
		kill "$(cat "$DQ_HOME/vm.pid")" 2>/dev/null || true
	fi
	rm -f "$DQ_HOME/vm.pid"
}

cmd_ssh() {
	ssh -p "$SSH_PORT" -o StrictHostKeyChecking=no root@localhost
}

cmd_status() {
	if [ -f "$DQ_HOME/vm.pid" ] && kill -0 "$(cat "$DQ_HOME/vm.pid")" 2>/dev/null; then
		echo "running (pid $(cat "$DQ_HOME/vm.pid"))"
	else
		echo "stopped"
	fi
}

case "${1:-}" in
	setup) cmd_setup ;;
	init) cmd_init ;;
	start) cmd_start ;;
	stop) cmd_stop ;;
	ssh) cmd_ssh ;;
	status) cmd_status ;;
	*) usage; exit 1 ;;
esac
