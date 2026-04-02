#!/system/bin/sh
# Auto Props Engine v25 — Powered by FN CREATIVE

PROPS="/data/props"
DBDIR="$PROPS/database"
LOG="$PROPS/autoprops.log"
CONF="$PROPS/autoprops.conf"

SAFE="/cache/.disable_autoprops"
LOCK="/dev/.fn_autoprops_engine.lock"

MANUAL="$PROPS/.manual_profile"
ROTATE_FLAG="$PROPS/.auto_rotate_profile"
LASTROT="$PROPS/.last_rotation"

log() {
	[ "${ENABLE_LOGGING:-1}" != "1" ] && return
	echo "[FN CREATIVE] $*" >> "$LOG" 2>/dev/null
}

_lc() {
	printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

_brand_match() {
	_real="$1"
	_row="$2"
	r="$(_lc "$_real")"
	b="$(_lc "$_row")"
	[ -n "$r" ] && [ -n "$b" ] || return 1
	[ "$r" = "$b" ] && return 0
	case "$r" in
	*xiaomi*|*redmi*|*poco*|*mi*)
		case "$b" in *xiaomi*|*redmi*|*poco*|*mi*) return 0 ;; esac
		;;
	esac
	case "$b" in
	*xiaomi*|*redmi*|*poco*|*mi*)
		case "$r" in *xiaomi*|*redmi*|*poco*|*mi*) return 0 ;; esac
		;;
	esac
	case "$r" in
	*oppo*|*realme*|*oneplus*)
		case "$b" in *oppo*|*realme*|*oneplus*) return 0 ;; esac
		;;
	esac
	case "$b" in
	*oppo*|*realme*|*oneplus*)
		case "$r" in *oppo*|*realme*|*oneplus*) return 0 ;; esac
		;;
	esac
	case "$r" in
	*vivo*|*iqoo*)
		case "$b" in *vivo*|*iqoo*) return 0 ;; esac
		;;
	esac
	case "$b" in
	*vivo*|*iqoo*)
		case "$r" in *vivo*|*iqoo*) return 0 ;; esac
		;;
	esac
	case "$b" in *"$r"*) return 0 ;; esac
	case "$r" in *"$b"*) [ "${#b}" -ge 3 ] && return 0 ;; esac
	return 1
}

_random_db_line() {
	n=0
	L=""
	while [ "$n" -lt 50 ]; do
		L=$(shuf -n 1 "$DB" 2>/dev/null)
		L=$(printf '%s' "$L" | tr -d '\r')
		case "$L" in
		''|\#*) n=$((n + 1)) ;;
		*) printf '%s' "$L"
			return 0 ;;
		esac
	done
	return 1
}

fn_unlock() {
	rm -f "$LOCK"
}

[ -f "$LOCK" ] && exit 0
: >"$LOCK"
trap fn_unlock EXIT HUP INT TERM

if [ -f "$SAFE" ]; then
	log "safe mode active — engine idle"
	exit 0
fi

[ -f "$CONF" ] && . "$CONF"

DB="${DATABASE_PATH:-$DBDIR/device_db.txt}"

if [ ! -f "$DB" ]; then
	log "database missing: $DB"
	exit 1
fi

log "engine start"

REAL_BRAND=$(getprop ro.product.brand)
REAL_MODEL=$(getprop ro.product.model)
REAL_SOC=$(getprop ro.board.platform)

log "device=$REAL_MODEL brand=$REAL_BRAND soc=$REAL_SOC"

if [ "${CALL_AI_SELECTOR:-0}" = "1" ] && [ -f "$PROPS/ai_selector.sh" ]; then
	sh "$PROPS/ai_selector.sh"
	log "ai selector completed"
fi

if [ "${CALL_HARDWARE_SELECTOR:-1}" != "0" ] && [ -f "$PROPS/hardware_selector.sh" ]; then
	sh "$PROPS/hardware_selector.sh"
	log "hardware selector completed"
fi

#################################
# Manual profile
#################################

if [ -f "$MANUAL" ]; then
	PROFILE=$(tr -d '\r' < "$MANUAL")
	setprop ro.product.model "$PROFILE"
	log "profile applied"
	exit 0
fi

#################################
# Rotation flag
#################################

if [ ! -f "$ROTATE_FLAG" ]; then
	log "rotation off — no .auto_rotate_profile"
	exit 0
fi

#################################
# Rotation timer (detik). 0 = tidak pernah skip lewat timer
#################################

RI=${ROTATE_INTERVAL:-86400}
case "$RI" in
''|*[!0-9]*) RI=86400 ;;
esac

if [ -f "$LASTROT" ] && [ "$RI" -gt 0 ]; then
	LAST=$(tr -d ' \r\n\t' < "$LASTROT")
	NOW=$(date +%s)
	DIFF=$((NOW - LAST))
	if [ "$DIFF" -lt "$RI" ]; then
		log "rotation skipped (timer ${DIFF}s < ${RI}s)"
		exit 0
	fi
fi

#################################
# Smart match (brand)
#################################

BEST=""

while IFS='|' read -r BRAND MODEL FP PATCH
do
	BRAND=$(printf '%s' "$BRAND" | tr -d '\r')
	case "$BRAND" in
	''|\#*) continue ;;
	esac
	_brand_match "$REAL_BRAND" "$BRAND" && {
		BEST="$BRAND|$MODEL|$FP|$PATCH"
		break
	}
done < "$DB"

if [ -z "$BEST" ]; then
	BEST=$(_random_db_line) || {
		log "fallback random failed"
		exit 1
	}
fi

LINE=$(printf '%s' "$BEST" | tr -d '\r')

BRAND=$(printf '%s\n' "$LINE" | cut -d'|' -f1)
MODEL=$(printf '%s\n' "$LINE" | cut -d'|' -f2)
FP=$(printf '%s\n' "$LINE" | cut -d'|' -f3)
PATCH=$(printf '%s\n' "$LINE" | cut -d'|' -f4)

#################################
# Apply spoof
#################################

[ -n "$BRAND" ] && setprop ro.product.brand "$BRAND"
[ -n "$MODEL" ] && setprop ro.product.model "$MODEL"
[ -n "$FP" ] && setprop ro.build.fingerprint "$FP"
[ -n "$PATCH" ] && setprop ro.build.version.security_patch "$PATCH"

log "profile applied"

date +%s >"$LASTROT" 2>/dev/null

log "rotation completed"

exit 0
