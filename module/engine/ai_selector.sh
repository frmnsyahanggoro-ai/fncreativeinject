#!/system/bin/sh
# Powered by FN CREATIVE — pemilih profil dari brand (dipanggil opsional dari engine).

LOG="/data/props/autoprops.log"

BRAND=$(getprop ro.product.brand)
SOC=$(getprop ro.board.platform)

echo "[FN CREATIVE] Detect brand=$BRAND soc=$SOC" >> "$LOG"

case "$BRAND" in

Samsung|samsung)
PROFILE="SM-G991B"
;;

Xiaomi|xiaomi|Redmi|redmi|POCO|poco)
PROFILE="Mi 11"
;;

Google|google)
PROFILE="Pixel 7"
;;

*)
PROFILE="Generic Android"
;;

esac

setprop ro.product.model "$PROFILE"

echo "[FN CREATIVE] AI profile applied $PROFILE" >> "$LOG"
