#!/system/bin/sh
# Powered by FN CREATIVE — boot: deploy via install.sh lalu engine.

MODDIR=${0%/*}

sleep 15

[ -d /data ] || exit 0

sh "$MODDIR/install.sh" --quiet --no-engine || true

[ -f "$MODDIR/engine/autoprops_engine.sh" ] && sh "$MODDIR/engine/autoprops_engine.sh"

exit 0
