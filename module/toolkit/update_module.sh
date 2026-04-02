#!/system/bin/sh
# Powered by FN CREATIVE — unduh ZIP modul terbaru (flash manual dari Magisk/KSU).

URL="${FN_MODULE_URL:-https://github.com/fncreative/fn-autoprops/releases/latest/download/module.zip}"
TMP="/data/local/tmp/fn_module_update.zip"

echo "[FN CREATIVE] Checking module update..."

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
	echo "[FN CREATIVE] Update downloaded → $TMP"
	echo "[FN CREATIVE] Flash ZIP from Magisk / KernelSU to update"
else
	echo "[FN CREATIVE] Update failed"
	rm -f "$TMP"
	exit 1
fi
