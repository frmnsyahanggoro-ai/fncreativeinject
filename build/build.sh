#!/usr/bin/env bash
# Powered by FN CREATIVE — ZIP akar modul: FN-CREATIVE-AutoProps-v25-Final.zip

set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OUT="$ROOT/FN-CREATIVE-AutoProps-v25-Final.zip"
MODULE="$ROOT/module"

echo "Building FN CREATIVE module..."

if command -v python3 >/dev/null 2>&1; then
	( cd "$ROOT" && python3 tools/build_banner.py ) || true
elif command -v python >/dev/null 2>&1; then
	( cd "$ROOT" && python tools/build_banner.py ) || true
fi

if [ -d "$ROOT/gui" ]; then
	mkdir -p "$MODULE/gui"
	for f in "$ROOT/gui/"*; do
		[ -f "$f" ] || continue
		name=$(basename "$f")
		case "$name" in
		README.txt|*.md|.gitkeep) continue ;;
		esac
		cp -f "$f" "$MODULE/gui/$name"
	done
fi

rm -f "$OUT"
(
	cd "$MODULE"
	zip -r "$OUT" . \
		-x "branding/*" \
		-x "*.bak"
)

echo "Build finished"
echo "$OUT"
