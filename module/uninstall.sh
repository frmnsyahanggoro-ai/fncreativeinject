#!/system/bin/sh
# Powered by FN CREATIVE

PROPS="/data/props"

rm -rf "$PROPS"

rm -f /cache/.disable_autoprops

rm -f /dev/.fn_autoprops_engine.lock
rm -f /dev/.celestial_engine.lock
rm -f /dev/.celestialcore.lock

exit 0
