#!/system/bin/sh
# Powered by FN CREATIVE

DB="/data/props/database/device_db.txt"

if [ ! -f "$DB" ]; then
	echo "ERROR: missing $DB"
	exit 1
fi

echo "===== Database stats (FN CREATIVE) ====="
echo ""

echo "Total lines (incl. blank/comments):"
wc -l <"$DB"

echo ""
echo "Data rows + Brand counts (skip # and empty):"

grep -v '^[[:space:]]*#' "$DB" | grep -v '^[[:space:]]*$' | cut -d'|' -f1 | sort | uniq -c | sort -nr
