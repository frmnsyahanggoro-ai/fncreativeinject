#!/system/bin/sh
# Powered by FN CREATIVE — gabung semua shard .txt → device_db.txt
# (Setara “cat shard*.txt”, dengan urutan tetap + skip device_db.txt & README.txt.)

DBDIR="${1:-/data/props/database}"
LOG="/data/props/autoprops.log"
TMP="$DBDIR/.device_db.merge.$$.tmp"
OUT="$DBDIR/device_db.txt"

mkdir -p "$DBDIR" 2>/dev/null
: >"$TMP"

for shard in samsung xiaomi oppo realme pixel oneplus others; do
	f="$DBDIR/${shard}.txt"
	if [ -f "$f" ]; then
		cat "$f" >>"$TMP"
	fi
done

if [ ! -s "$TMP" ]; then
	rm -f "$TMP"
	echo "[FN CREATIVE] database merge failed (no shards)" >>"$LOG" 2>/dev/null
	echo "[FN CREATIVE] database merge failed (no shards)"
	exit 1
fi

mv "$TMP" "$OUT"
chmod 600 "$OUT" 2>/dev/null

echo "[FN CREATIVE] database rebuilt" >>"$LOG" 2>/dev/null
echo "[FN CREATIVE] database rebuilt"
