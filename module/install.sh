#!/system/bin/sh
# FN CREATIVE — instalasi / perbaikan satu kali (Magisk / KernelSU / su)
# One-click: su -c "sh /data/adb/modules/fn_autoprops/install.sh"
# Atau dari folder modul: su -c "sh $(pwd)/install.sh"
#
# Opsi: --quiet (log minimal)  --no-engine (tidak jalankan autoprops_engine)
#       --no-merge (lewati build_database.sh)

QUIET=0
NO_ENGINE=0
NO_MERGE=0

for _a in "$@"; do
	case "$_a" in
	--quiet) QUIET=1 ;;
	--no-engine) NO_ENGINE=1 ;;
	--no-merge) NO_MERGE=1 ;;
	esac
done

case "$0" in
/*) MODDIR=$(dirname "$0") ;;
*) MODDIR=$(cd "$(dirname "$0")" && pwd) 2>/dev/null || MODDIR=$(dirname "$0") ;;
esac

ILOG="/data/props/install.log"
PROPS="/data/props"
DBDIR="$PROPS/database"
LOG="$PROPS/autoprops.log"

log() {
	_ts=$(date "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo -n "?")
	_line="[$_ts] [FN CREATIVE] $*"
	mkdir -p "$PROPS" 2>/dev/null
	echo "$_line" >>"$ILOG" 2>/dev/null || true
	[ "$QUIET" = 1 ] || echo "$_line"
}

die() {
	log "ERROR: $*"
	exit 1
}

if [ "$(id -u)" != "0" ]; then
	die "jalankan sebagai root: su -c \"sh $0\""
fi

if [ ! -d /data ]; then
	die "/data tidak tersedia"
fi

if [ ! -f "$MODDIR/module.prop" ]; then
	for _try in /data/adb/modules/fn_autoprops /data/adb/modules_update/fn_autoprops /data/adb/ksu/modules/fn_autoprops; do
		if [ -f "$_try/module.prop" ]; then
			MODDIR="$_try"
			break
		fi
	done
fi

[ -f "$MODDIR/module.prop" ] || die "module.prop tidak ditemukan — set FN_MODDIR atau flash modul"

log "install start MODDIR=$MODDIR"

mkdir -p "$PROPS" "$DBDIR" || die "mkdir $PROPS"
chmod 700 "$PROPS" "$DBDIR" 2>/dev/null || true
[ -f "$LOG" ] || : >"$LOG"
chmod 600 "$LOG" 2>/dev/null || true

if [ ! -f "$PROPS/autoprops.conf" ] && [ -f "$MODDIR/config/autoprops.conf" ]; then
	cp "$MODDIR/config/autoprops.conf" "$PROPS/autoprops.conf" || die "copy autoprops.conf"
	chmod 600 "$PROPS/autoprops.conf" 2>/dev/null || true
	log "config seeded"
fi

if [ -d "$MODDIR/database" ]; then
	for f in "$MODDIR/database/"*; do
		[ -f "$f" ] || continue
		_name=$(basename "$f")
		case "$_name" in
		README.txt) continue ;;
		esac
		cp -f "$f" "$DBDIR/$_name" || log "warn: copy database/$_name"
		chmod 600 "$DBDIR/$_name" 2>/dev/null || true
	done
	log "database shards synced"
fi

if [ -d "$MODDIR/engine" ]; then
	mkdir -p "$PROPS/engine"
	for f in "$MODDIR/engine/"*.sh; do
		[ -f "$f" ] || continue
		_name=$(basename "$f")
		cp -f "$f" "$PROPS/engine/$_name" || log "warn: engine/$_name"
		chmod 755 "$PROPS/engine/$_name" 2>/dev/null || true
	done
	for _hook in ai_selector hardware_selector; do
		if [ -f "$MODDIR/engine/$_hook.sh" ]; then
			cp -f "$MODDIR/engine/$_hook.sh" "$PROPS/$_hook.sh"
			chmod 755 "$PROPS/$_hook.sh" 2>/dev/null || true
		fi
	done
	log "engine synced"
fi

if [ -d "$MODDIR/toolkit" ]; then
	for f in "$MODDIR/toolkit/"*.sh; do
		[ -f "$f" ] || continue
		_name=$(basename "$f")
		cp -f "$f" "$PROPS/$_name"
		chmod 755 "$PROPS/$_name" 2>/dev/null || true
	done
	log "toolkit synced"
fi

if [ -d "$MODDIR/gui" ]; then
	mkdir -p "$PROPS/gui"
	for f in "$MODDIR/gui/"*; do
		[ -f "$f" ] || continue
		_name=$(basename "$f")
		case "$_name" in
		README.txt|*.md|.gitkeep) continue ;;
		esac
		cp -f "$f" "$PROPS/gui/$_name"
		chmod 644 "$PROPS/gui/$_name" 2>/dev/null || true
	done
	log "gui synced"
fi

if [ "$NO_MERGE" != 1 ] && [ ! -f "$DBDIR/.remote_db" ] && [ -f "$PROPS/build_database.sh" ]; then
	if sh "$PROPS/build_database.sh" "$DBDIR"; then
		log "device_db.txt rebuilt"
	else
		log "warn: build_database.sh failed"
	fi
fi

log "install finish OK"

if [ "$NO_ENGINE" != 1 ] && [ -f "$MODDIR/engine/autoprops_engine.sh" ]; then
	sh "$MODDIR/engine/autoprops_engine.sh" || log "warn: autoprops_engine exit non-zero"
fi

exit 0
