#!/bin/bash
# Local ZMK build + flash helper for Aquila.
# Usage:
#   ./flash.sh <shield> [extra -D cmake args...]
# Examples:
#   ./flash.sh aquila_left
#   ./flash.sh aquila_right
#   ./flash.sh aquila_left -DCONFIG_ZMK_USB_LOGGING=y
#
# Builds locally against ~/Projects/zmk-workspace, then waits for the
# NICENANO bootloader drive (double-tap reset) and copies the UF2.

set -e
export PATH="/opt/homebrew/bin:$PATH"
export ZEPHYR_SDK_INSTALL_DIR="$HOME/zephyr-sdk-0.17.0"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr

WS="$HOME/Projects/zmk-workspace"
CONFIG="$HOME/Projects/zmk-aquila/config"
WEST="$HOME/Projects/zmk-workspace-venv/bin/west"

SHIELD="${1:?usage: ./flash.sh <shield> [extra -D args]}"
shift || true

echo ">>> Building $SHIELD locally..."
cd "$WS"
"$WEST" build -s zmk/app -d "build/$SHIELD" -b "nice_nano//zmk" -p=auto -- \
    -DSHIELD="$SHIELD" -DZMK_CONFIG="$CONFIG" "$@"

UF2="$WS/build/$SHIELD/zephyr/zmk.uf2"
echo ">>> Built $(ls -la "$UF2" | awk '{print $5}') bytes."
echo ">>> Double-tap reset on the target half now (waiting for NICENANO)..."

for i in $(seq 1 300); do
    if [ -d /Volumes/NICENANO ]; then
        for t in 1 2 3 4 5; do
            if cp -X "$UF2" /Volumes/NICENANO/ 2>/dev/null; then
                echo ">>> Flashed $SHIELD (try $t). Board will reboot."
                exit 0
            fi
            sleep 1
        done
        echo "!!! Copy failed after 5 tries."; exit 1
    fi
    sleep 1
done
echo "!!! No NICENANO drive appeared in 5 minutes."; exit 1
