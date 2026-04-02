#!/system/bin/sh
# Powered by FN CREATIVE — unduh device_db.txt dari raw GitHub

DBDIR="/data/props/database"
URL="${FN_DB_URL:-https://raw.githubusercontent.com/fncreative/device-db/main/device_db.txt}"
TMP="/data/local/tmp/device_db.txt"

echo "[FN CREATIVE] Checking database update..."

mkdir -p "$DBDIR" 2>/dev/null

rm -f "$TMP"

if command -v wget >/dev/null 2>&1; then
	wget -O "$TMP" "$URL" 2>/dev/null
elif command -v curl >/dev/null 2>&1; then
	curl -fsSL -o "$TMP" "$URL" 2>/dev/null
else
	echo "[FN CREATIVE] Update failed (no wget/curl)"
	exit 1
fi

if [ -f "$TMP" ] && [ -s "$TMP" ]; then
	mv "$TMP" "$DBDIR/device_db.txt"
	chmod 600 "$DBDIR/device_db.txt" 2>/dev/null
	: >"$DBDIR/.remote_db"
	echo "[FN CREATIVE] database updated"
else
	echo "[FN CREATIVE] Update failed"
	rm -f "$TMP"
	exit 1
fi
