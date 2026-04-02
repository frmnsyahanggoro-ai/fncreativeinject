#!/system/bin/sh
# Powered by FN CREATIVE

PROPS="/data/props"
DBDIR="$PROPS/database"
LOG="$PROPS/autoprops.log"

[ -d /data ] || exit 0

mkdir -p "$PROPS"
mkdir -p "$DBDIR"

chmod 700 "$PROPS" 2>/dev/null
chmod 700 "$DBDIR" 2>/dev/null

[ -f "$LOG" ] || touch "$LOG"

echo "[FN CREATIVE] init $(date)" >> "$LOG"

exit 0
